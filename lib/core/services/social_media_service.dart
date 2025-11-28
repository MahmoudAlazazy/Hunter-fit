import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:io';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart' as app_user;

class SocialMediaService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Cache for better performance
  final Map<String, List<Post>> _postsCache = {};
  final Map<String, List<Comment>> _commentsCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 1);
  
  // Error handling and retry logic
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  // Fetch original post data for shared posts
  Future<void> enrichPostsWithOriginalData(List<Post> posts) async {
    final sharedPostIds = posts.where((p) => p.isShared && p.originalPostId != null).map((p) => p.originalPostId!).toSet().toList();
    
    if (sharedPostIds.isEmpty) return;
    
    try {
      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .inFilter('id', sharedPostIds);
      
      final originalPostsMap = {for (var post in response) post['id']: Post.fromJson(post)};
      
      // Update posts with their original post data
      for (var post in posts) {
        if (post.isShared && post.originalPostId != null) {
          final originalPost = originalPostsMap[post.originalPostId];
          if (originalPost != null) {
            post.copyWith(originalPost: originalPost);
          }
        }
      }
    } catch (e) {
      print('Error fetching original posts: $e');
    }
  }

  // Fetch posts with original post data for shared posts
  Future<List<Post>> fetchPosts({String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
      // Check cache first
      const cacheKey = 'posts_all';
      if (_isCacheValid(cacheKey)) {
        print('Returning cached posts');
        return _postsCache[cacheKey]!;
      }

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) {
        final post = Post.fromJson(json);
        
        // Update posts with current user profile data if this is the current user's post
        final updatedPost = post.copyWith(
          userName: currentUserName != null && post.userName == null ? currentUserName : post.userName,
          userPhotoUrl: currentUserPhotoUrl != null && post.userPhotoUrl == null ? currentUserPhotoUrl : post.userPhotoUrl,
        );
        
        return updatedPost;
      }).toList();
      
      // Cache the results
      _postsCache[cacheKey] = posts;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      // Enrich shared posts with original post data
      await enrichPostsWithOriginalData(posts);
      
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      // Try to return cached data if available
      const cacheKey = 'posts_all';
      if (_postsCache.containsKey(cacheKey)) {
        print('Returning stale cached posts due to error');
        return _postsCache[cacheKey]!;
      }
      rethrow;
    }
  }

  Future<List<Post>> fetchUserPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
      // Check cache first
      final cacheKey = 'posts_user_$userId';
      if (_isCacheValid(cacheKey)) {
        print('Returning cached user posts for user $userId');
        return _postsCache[cacheKey]!;
      }

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) => Post.fromJson(json)).toList();
      
      // Update posts with current user profile data if this is the current user's post
      final updatedPosts = posts.map((post) {
        if (currentUserName != null && post.userName == null) {
          return post.copyWith(userName: currentUserName);
        }
        if (currentUserPhotoUrl != null && post.userPhotoUrl == null) {
          return post.copyWith(userPhotoUrl: currentUserPhotoUrl);
        }
        return post;
      }).toList();
      
      // Cache the results
      _postsCache[cacheKey] = updatedPosts;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return updatedPosts;
    } catch (e) {
      print('Error fetching user posts: $e');
      // Try to return cached data if available
      final cacheKey = 'posts_user_$userId';
      if (_postsCache.containsKey(cacheKey)) {
        print('Returning stale cached user posts due to error');
        return _postsCache[cacheKey]!;
      }
      rethrow;
    }
  }

  Future<List<Post>> fetchFriendsPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
        final followingIdsResponse = await _supabase
          .from('user_follows')
          .select('following_id')
          .eq('follower_id', userId);

      final followingIds = (followingIdsResponse as List)
          .map((item) => item['following_id'] as String)
          .toList();

      if (followingIds.isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('posts')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .inFilter('user_id', followingIds)
          .order('created_at', ascending: false);

      final posts = (response as List).map((json) => Post.fromJson(json)).toList();

      return posts.map((post) {
        if (currentUserName != null && post.userName == null) {
          return post.copyWith(userName: currentUserName);
        }
        if (currentUserPhotoUrl != null && post.userPhotoUrl == null) {
          return post.copyWith(userPhotoUrl: currentUserPhotoUrl);
        }
        return post;
      }).toList();
    } catch (e) {
      print('Error fetching friends posts: $e');
      rethrow;
    }
  }

  Future<List<Post>> fetchFeedPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
      if (userId.trim().isEmpty) {
        // Guest user - fetch only public posts
        final response = await _supabase
            .from('posts')
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .eq('visibility', 'public')
            .order('created_at', ascending: false)
            .limit(20);

        final posts = (response as List).map((json) => Post.fromJson(json)).toList();
        
        // Update posts with current user profile data if this is the current user's post
        return posts.map((post) {
          if (currentUserName != null && post.userName == null) {
            return post.copyWith(userName: currentUserName);
          }
          if (currentUserPhotoUrl != null && post.userPhotoUrl == null) {
            return post.copyWith(userPhotoUrl: currentUserPhotoUrl);
          }
          return post;
        }).toList();
      }

      // Logged-in user - fetch posts from followed users and public posts
      final response = await _supabase
        .from('posts')
        .select('''
          *,
          profiles:user_id (
            id,
            username,
            avatar_url
          )
        ''')
        .or('visibility.eq.public,user_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(50);

      final posts = (response as List).map((json) => Post.fromJson(json)).toList();
      
      // Update posts with current user profile data if this is the current user's post
      final updatedPosts = posts.map((post) {
        if (currentUserName != null && post.userName == null) {
          return post.copyWith(userName: currentUserName);
        }
        if (currentUserPhotoUrl != null && post.userPhotoUrl == null) {
          return post.copyWith(userPhotoUrl: currentUserPhotoUrl);
        }
        return post;
      }).toList();
      
      // Enrich shared posts with original post data
      await enrichPostsWithOriginalData(updatedPosts);
      
      return updatedPosts;
    } catch (e) {
      print('Error fetching feed posts: $e');
      rethrow;
    }
  }

  Future<Post?> createPost({
    required String userId,
    required String content,
    String? imagePath,
    String? imageUrl,
    bool isPublic = true,
    String? userName,
    String? userPhotoUrl,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final response = await _supabase
            .from('posts')
            .insert({
              'user_id': userId,
              'content': content,
              'image_url': imageUrl,
              'visibility': isPublic ? 'public' : 'private',
            })
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .single();

        // Create post with user profile data from auth provider
        final post = Post.fromJson(response);
        final newPost = post.copyWith(
          userName: userName ?? post.userName,
          userPhotoUrl: userPhotoUrl ?? post.userPhotoUrl,
        );

        // Don't clear cache immediately - let it expire naturally
        // This prevents posts from disappearing after creation
        // The new post will appear when cache expires or on manual refresh
        
        return newPost;
      } catch (e) {
        print('Error creating post (attempt ${retries + 1}): $e');
        
        if (retries < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (retries + 1));
          retries++;
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  Future<bool> deletePost(String postId, String userId) async {
    try {
      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  Future<Post?> sharePost({
    required String originalPostId,
    required String sharedByUserId,
    required String sharedContent,
    bool isPublic = true,
    String? userName,
    String? userPhotoUrl,
  }) async {
    int retries = 0;
    
    while (retries < _maxRetries) {
      try {
        // Get the original post
        final originalPostResponse = await _supabase
            .from('posts')
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .eq('id', originalPostId)
            .single();

        final originalPost = Post.fromJson(originalPostResponse);

        // Create the shared post with original post data
        final sharedPostResponse = await _supabase
            .from('posts')
            .insert({
              'user_id': sharedByUserId,
              'content': sharedContent,
              'visibility': isPublic ? 'public' : 'private',
              'is_shared': true,
              'original_post_id': originalPostId,
              'shared_by_user_id': sharedByUserId,
              'shared_at': DateTime.now().toIso8601String(),
            })
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .single();

        final sharedPost = Post.fromJson(sharedPostResponse);
        final newSharedPost = sharedPost.copyWith(
          userName: userName ?? sharedPost.userName,
          userPhotoUrl: userPhotoUrl ?? sharedPost.userPhotoUrl,
          originalPost: originalPost, // Add the original post data
        );

        // Don't clear cache immediately - let it expire naturally
        // This prevents posts from disappearing after sharing
        
        return newSharedPost;
      } catch (e) {
        print('Error sharing post (attempt ${retries + 1}): $e');
        
        if (retries < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (retries + 1));
          retries++;
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  Future<bool> toggleLike(String userId, {String? postId, String? commentId}) async {
    int retries = 0;
    
    while (retries < _maxRetries) {
      try {
        if (postId != null) {
          // Check if like exists
          final existingLike = await _supabase
              .from('likes')
              .select()
              .eq('user_id', userId)
              .eq('post_id', postId)
              .maybeSingle();

          if (existingLike != null) {
            // Remove like
            await _supabase
                .from('likes')
                .delete()
                .eq('user_id', userId)
                .eq('post_id', postId);
            
            // Don't clear cache immediately - let it expire naturally
            // This prevents posts from disappearing after unlikes
            return false;
          } else {
            // Add like
            await _supabase
                .from('likes')
                .insert({'user_id': userId, 'post_id': postId});
            
            // Don't clear cache immediately - let it expire naturally
            // This prevents posts from disappearing after likes
            return true;
          }
        } else if (commentId != null) {
          // Similar logic for comment likes
          final existingLike = await _supabase
              .from('likes')
              .select()
              .eq('user_id', userId)
              .eq('comment_id', commentId)
              .maybeSingle();

          if (existingLike != null) {
            await _supabase
                .from('likes')
                .delete()
                .eq('user_id', userId)
                .eq('comment_id', commentId);
            return false;
          } else {
            await _supabase
                .from('likes')
                .insert({'user_id': userId, 'comment_id': commentId});
            return true;
          }
        }
        return false;
      } catch (e) {
        print('Error toggling like (attempt ${retries + 1}): $e');
        
        if (retries < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (retries + 1));
          retries++;
        } else {
          rethrow;
        }
      }
    }
    
    return false;
  }

  Future<bool> isLikedByUser(String userId, {String? postId, String? commentId}) async {
    try {
      if (postId != null) {
        final response = await _supabase
            .from('likes')
            .select()
            .eq('user_id', userId)
            .eq('post_id', postId)
            .maybeSingle();
        return response != null;
      } else if (commentId != null) {
        final response = await _supabase
            .from('likes')
            .select()
            .eq('user_id', userId)
            .eq('comment_id', commentId)
            .maybeSingle();
        return response != null;
      }
      return false;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // Comment-related methods
  
  Future<List<Comment>> fetchComments(String postId) async {
    try {
      // Check cache first
      final cacheKey = 'comments_post_$postId';
      if (_isCacheValid(cacheKey)) {
        print('Returning cached comments for post $postId');
        return _commentsCache[cacheKey]!;
      }

      final response = await _supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true);

      final comments = (response as List).map((json) {
        final comment = Comment.fromJson(json);
        
        // Add fallback user data if profile is missing
        final fallbackUsername = json['user_metadata']?['username'] ?? json['email']?.split('@')[0];
        final fallbackAvatar = json['user_metadata']?['avatar_url'];
        
        return comment.copyWith(
          userName: comment.userName ?? fallbackUsername,
          userPhotoUrl: comment.userPhotoUrl ?? fallbackAvatar,
        );
      }).toList();
      
      // Cache the results
      _commentsCache[cacheKey] = comments;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return comments;
    } catch (e) {
      print('Error fetching comments: $e');
      // Try to return cached data if available
      final cacheKey = 'comments_post_$postId';
      if (_commentsCache.containsKey(cacheKey)) {
        print('Returning stale cached comments due to error');
        return _commentsCache[cacheKey]!;
      }
      rethrow;
    }
  }

  Future<Comment?> createComment({
    required String postId,
    required String userId,
    required String content,
    String? commentImage,
  }) async {
    // Validate UUID inputs
    if (postId.trim().isEmpty || userId.trim().isEmpty) {
      throw ArgumentError('Post ID and User ID cannot be empty');
    }
    
    int retries = 0;
    
    while (retries < _maxRetries) {
      try {
        final response = await _supabase
            .from('comments')
            .insert({
              'post_id': postId,
              'user_id': userId,
              'content': content,
            })
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .single();

        // Get current user metadata for fallback
        final currentUser = _supabase.auth.currentUser;
        final fallbackUsername = currentUser?.userMetadata?['username'] ?? currentUser?.email?.split('@')[0];
        final fallbackAvatar = currentUser?.userMetadata?['avatar_url'];

        final comment = Comment.fromJson(response);
        
        // Add fallback user data if profile is missing
        final finalComment = comment.copyWith(
          userName: comment.userName ?? fallbackUsername,
          userPhotoUrl: comment.userPhotoUrl ?? fallbackAvatar,
        );
        
        // Clear comment cache for this post
        clearCacheForKey('comments_post_$postId');
        
        return finalComment;
      } catch (e) {
        print('Error creating comment (attempt ${retries + 1}): $e');
        
        if (retries < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (retries + 1));
          retries++;
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  Future<bool> deleteComment(String commentId, String userId) async {
    try {
      await _supabase
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Comment reply methods
  
  Future<Comment?> createReply({
    required String postId,
    required String userId,
    required String content,
    required String parentCommentId,
    String? commentImage,
  }) async {
    int retries = 0;

    while (retries < _maxRetries) {
      try {
        final response = await _supabase
            .from('comments')
            .insert({
              'post_id': postId,
              'user_id': userId,
              'content': content,
              'comment_image': commentImage,
              'parent_comment_id': parentCommentId,
              'is_reply': true,
            })
            .select('''
              *,
              profiles:user_id (
                id,
                username,
                avatar_url
              )
            ''')
            .single();

        final reply = Comment.fromJson(response);
        
        // Clear comment cache for this post
        clearCacheForKey('comments_post_$postId');
        
        // The replies_count will be automatically updated by the trigger
        return reply;
      } catch (e) {
        print('Error creating reply (attempt ${retries + 1}): $e');
        
        if (retries < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (retries + 1));
          retries++;
        } else {
          rethrow;
        }
      }
    }
    
    return null;
  }

  Future<List<Comment>> fetchCommentReplies(String parentCommentId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select('''
            *,
            users:user_id (
              id,
              username,
              avatar_url
            )
          ''')
          .eq('parent_comment_id', parentCommentId)
          .eq('is_reply', true)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching comment replies: $e');
      rethrow;
    }
  }

  // User and following methods
  
  Future<List<app_user.User>> getAllUsersWithProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List).map((json) => app_user.User.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<Map<String, bool>> checkFollowingStatus(String currentUserId, List<String> userIds) async {
    try {
      // If current user ID is null/empty (guest) or no userIds provided, return all false
      if (currentUserId.trim().isEmpty || userIds.isEmpty) {
        return {for (var id in userIds) id: false};
      }
      final response = await _supabase
          .from('user_follows')
          .select('following_id')
          .eq('follower_id', currentUserId)
          .inFilter('following_id', userIds);

      final followingIds = (response as List).map((item) => item['following_id']?.toString()).toSet();

      return {for (var id in userIds) id: followingIds.contains(id)};
    } catch (e) {
      print('Error checking following status: $e');
      return {};
    }
  }

  Future<bool> followUser(String followerId, String followingId) async {
    // Validate UUID inputs
    if (followerId.trim().isEmpty || followingId.trim().isEmpty) {
      print('Error: followerId and followingId cannot be empty');
      return false;
    }
    
    try {
        await _supabase
          .from('user_follows')
          .insert({'follower_id': followerId, 'following_id': followingId});
      return true;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String followerId, String followingId) async {
    // Validate UUID inputs
    if (followerId.trim().isEmpty || followingId.trim().isEmpty) {
      print('Error: followerId and followingId cannot be empty');
      return false;
    }
    
    try {
        await _supabase
          .from('user_follows')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      return true;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  // Bookmark methods
  
  Future<bool> toggleBookmark(String postId, String userId) async {
    try {
      final existingBookmark = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();

      if (existingBookmark != null) {
        await _supabase
            .from('bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);
        return false;
      } else {
        await _supabase
            .from('bookmarks')
            .insert({'user_id': userId, 'post_id': postId});
        return true;
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      rethrow;
    }
  }

  Future<bool> isPostBookmarked(String postId, String userId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('post_id', postId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print('Error checking bookmark status: $e');
      return false;
    }
  }

  // Post views
  
  Future<void> recordPostView(String postId, {String? userId}) async {
    try {
      await _supabase
          .from('post_views')
          .insert({'post_id': postId, 'user_id': userId});
    } catch (e) {
      print('Error recording post view: $e');
    }
  }

  // Force refresh all posts cache
  Future<void> forceRefreshAllPosts() async {
    // Clear all post-related caches
    _postsCache.clear();
    _cacheTimestamps.clear();
    
    // Wait a moment to ensure cache is cleared
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('Force refreshed all posts cache');
  }

  // Refresh all posts cache
  void refreshAllPostsCache() {
    clearCacheForKey('posts_all');
    clearCacheForKey('posts_feed');
  }

  // Cache management methods
  bool _isCacheValid(String cacheKey) {
    if (!_cacheTimestamps.containsKey(cacheKey)) {
      return false;
    }
    
    final cacheTime = _cacheTimestamps[cacheKey]!;
    final now = DateTime.now();
    
    return now.difference(cacheTime) < _cacheDuration;
  }

  // Image upload
  Future<String?> uploadPostImage(String imagePath, String userId) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        print('Image file does not exist: $imagePath');
        return null;
      }

      final fileName = 'post_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = 'posts/$userId/$fileName';

      await _supabase.storage.from('posts').upload(
        filePath,
        file,
      );

      // Get the public URL
      final publicUrl = _supabase.storage.from('posts').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Clear all cache
  void clearCache() {
    _postsCache.clear();
    _commentsCache.clear();
    _cacheTimestamps.clear();
    print('Social media cache cleared');
  }

  // Clear specific cache
  void clearCacheForKey(String cacheKey) {
    _postsCache.remove(cacheKey);
    _commentsCache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
    print('Cache cleared for key: $cacheKey');
  }
}
