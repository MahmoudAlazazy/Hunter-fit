import 'package:flutter/foundation.dart';
import '../core/services/social_media_service.dart';
import '../core/models/post_model.dart';
import '../core/models/comment_model.dart';
import '../core/models/user_model.dart' as app_user;

class SocialMediaProvider with ChangeNotifier {
  final SocialMediaService _socialMediaService = SocialMediaService();

  // Posts
  List<Post> _posts = [];
  List<Post> _feedPosts = [];
  bool _isLoadingPosts = false;
  String? _postsError;

  // Comments
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  String? _commentsError;

  // Users
  List<app_user.User> _users = [];
  Map<String, bool> _followingStatus = {};
  bool _isLoadingUsers = false;
  String? _usersError;

  // Getters
  List<Post> get posts => _posts;
  List<Post> get feedPosts => _feedPosts;
  bool get isLoadingPosts => _isLoadingPosts;
  String? get postsError => _postsError;

  List<Comment> get comments => _comments;
  bool get isLoadingComments => _isLoadingComments;
  String? get commentsError => _commentsError;

  List<app_user.User> get users => _users;
  Map<String, bool> get followingStatus => _followingStatus;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get usersError => _usersError;

  // Post methods
  
  Future<void> fetchPosts({String? currentUserName, String? currentUserPhotoUrl}) async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      _posts = await _socialMediaService.fetchPosts(
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    } catch (e) {
      _postsError = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      _posts = await _socialMediaService.fetchUserPosts(
        userId,
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    } catch (e) {
      _postsError = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> fetchFriendsPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      _posts = await _socialMediaService.fetchFriendsPosts(
        userId,
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    } catch (e) {
      _postsError = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeedPosts(String userId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    _isLoadingPosts = true;
    _postsError = null;
    notifyListeners();

    try {
      _feedPosts = await _socialMediaService.fetchFeedPosts(
        userId,
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    } catch (e) {
      _postsError = e.toString();
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String userId,
    required String content,
    String? imagePath,
    String? imageUrl,
    bool isPublic = true,
    String? userName,
    String? userPhotoUrl,
  }) async {
    try {
      // If imagePath is provided, upload it first
      String? finalImageUrl = imageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        finalImageUrl = await _socialMediaService.uploadPostImage(imagePath, userId);
      }

      final newPost = await _socialMediaService.createPost(
        userId: userId,
        content: content,
        imagePath: imagePath,
        imageUrl: finalImageUrl,
        isPublic: isPublic,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
      );

      if (newPost != null) {
        _posts.insert(0, newPost);
        _feedPosts.insert(0, newPost);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId, String userId) async {
    try {
      final success = await _socialMediaService.deletePost(postId, userId);
      if (success) {
        _posts.removeWhere((post) => post.id == postId);
        _feedPosts.removeWhere((post) => post.id == postId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  Future<bool> sharePost({
    required String originalPostId,
    required String sharedByUserId,
    required String sharedContent,
    bool isPublic = true,
    String? userName,
    String? userPhotoUrl,
  }) async {
    try {
      final sharedPost = await _socialMediaService.sharePost(
        originalPostId: originalPostId,
        sharedByUserId: sharedByUserId,
        sharedContent: sharedContent,
        isPublic: isPublic,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
      );

      if (sharedPost != null) {
        _posts.insert(0, sharedPost);
        _feedPosts.insert(0, sharedPost);
        Future.microtask(() => notifyListeners());
        
        // Force refresh cache to ensure persistence
        Future.delayed(const Duration(milliseconds: 500), () {
          _socialMediaService.forceRefreshAllPosts();
        });
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error sharing post: $e');
      return false;
    }
  }

  Future<bool> toggleLike(String userId, {String? postId, String? commentId}) async {
    try {
      final newLikeStatus = await _socialMediaService.toggleLike(userId, postId: postId, commentId: commentId);
      
      // Update local state
      if (postId != null) {
        final postIndex = _feedPosts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _feedPosts[postIndex];
          _feedPosts[postIndex] = post.copyWith(
            likesCount: newLikeStatus ? post.likesCount + 1 : post.likesCount - 1,
          );
        }
        
        // Also update posts list if it exists
        final postsIndex = _posts.indexWhere((post) => post.id == postId);
        if (postsIndex != -1) {
          final post = _posts[postsIndex];
          _posts[postsIndex] = post.copyWith(
            likesCount: newLikeStatus ? post.likesCount + 1 : post.likesCount - 1,
          );
        }
      }
      
      Future.microtask(() => notifyListeners());
      
      // Refresh cache after a short delay to ensure consistency
      Future.delayed(const Duration(milliseconds: 500), () {
        _socialMediaService.forceRefreshAllPosts();
      });
      
      return newLikeStatus;
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

      Future<bool> isLikedByUser(String userId, {String? postId, String? commentId}) async {
    try {
      return await _socialMediaService.isLikedByUser(userId, postId: postId, commentId: commentId);
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // Comment methods
  
      Future<void> fetchComments(String postId) async {
    _isLoadingComments = true;
    _commentsError = null;
    notifyListeners();

    try {
      _comments = await _socialMediaService.fetchComments(postId);
    } catch (e) {
      _commentsError = e.toString();
    } finally {
      _isLoadingComments = false;
      notifyListeners();
    }
  }

  Future<bool> createComment({
    required String postId,
    required String userId,
    required String content,
    String? commentImage,
  }) async {
    try {
      final newComment = await _socialMediaService.createComment(
        postId: postId,
        userId: userId,
        content: content,
        commentImage: commentImage,
      );

      if (newComment != null) {
        _comments.add(newComment);
        
        // Update post comment count
        final postIndex = _feedPosts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _feedPosts[postIndex];
          _feedPosts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }
        
        // Also update posts list if it exists
        final postsIndex = _posts.indexWhere((post) => post.id == postId);
        if (postsIndex != -1) {
          final post = _posts[postsIndex];
          _posts[postsIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }
        
        Future.microtask(() => notifyListeners());
        
        // Refresh cache after a short delay to ensure consistency
        Future.delayed(const Duration(milliseconds: 500), () {
          _socialMediaService.forceRefreshAllPosts();
        });
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating comment: $e');
      return false;
    }
  }

      Future<bool> deleteComment(String commentId, String userId, String postId) async {
    try {
      final success = await _socialMediaService.deleteComment(commentId, userId);
      if (success) {
        _comments.removeWhere((comment) => comment.id == commentId);
        
        // Update post comment count
        final postIndex = _feedPosts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _feedPosts[postIndex];
          _feedPosts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount - 1,
          );
        }
        
        // Also update posts list if it exists
        final postsIndex = _posts.indexWhere((post) => post.id == postId);
        if (postsIndex != -1) {
          final post = _posts[postsIndex];
          _posts[postsIndex] = post.copyWith(
            commentsCount: post.commentsCount - 1,
          );
        }
        
        Future.microtask(() => notifyListeners());
        
        // Force refresh cache to ensure persistence
        Future.delayed(const Duration(milliseconds: 500), () {
          _socialMediaService.forceRefreshAllPosts();
        });
      }
      return success;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  // Comment reply methods
  
  Future<bool> createReply({
    required String postId,
    required String userId,
    required String content,
    required String parentCommentId,
    String? commentImage,
  }) async {
    try {
      final newReply = await _socialMediaService.createReply(
        postId: postId,
        userId: userId,
        content: content,
        parentCommentId: parentCommentId,
        commentImage: commentImage,
      );

      if (newReply != null) {
        _comments.add(newReply);
        
        // Update post comment count
        final postIndex = _feedPosts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _feedPosts[postIndex];
          _feedPosts[postIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }
        
        // Also update posts list if it exists
        final postsIndex = _posts.indexWhere((post) => post.id == postId);
        if (postsIndex != -1) {
          final post = _posts[postsIndex];
          _posts[postsIndex] = post.copyWith(
            commentsCount: post.commentsCount + 1,
          );
        }
        
        Future.microtask(() => notifyListeners());
        
        // Force refresh cache to ensure persistence
        Future.delayed(const Duration(milliseconds: 500), () {
          _socialMediaService.forceRefreshAllPosts();
        });
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating reply: $e');
      return false;
    }
  }

      Future<List<Comment>> fetchCommentReplies(String parentCommentId) async {
    try {
      return await _socialMediaService.fetchCommentReplies(parentCommentId);
    } catch (e) {
      print('Error fetching comment replies: $e');
      return [];
    }
  }

  // User methods
  
  Future<void> getAllUsersWithProfiles() async {
    _isLoadingUsers = true;
    _usersError = null;
    notifyListeners();

    try {
      _users = await _socialMediaService.getAllUsersWithProfiles();
    } catch (e) {
      _usersError = e.toString();
    } finally {
      _isLoadingUsers = false;
      // Use microtask to avoid build phase issues
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> checkFollowingStatus(String currentUserId, List<String> userIds) async {
    try {
      _followingStatus = await _socialMediaService.checkFollowingStatus(currentUserId, userIds);
      // Use microtask to avoid build phase issues
      Future.microtask(() => notifyListeners());
    } catch (e) {
      print('Error checking following status: $e');
    }
  }

  Future<bool> followUser(String followerId, String followingId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
      final success = await _socialMediaService.followUser(followerId, followingId);
      if (success) {
        _followingStatus[followingId] = true;
        Future.microtask(() => notifyListeners());
        // Refresh the feed posts for the follower to include posts from followed user
        await fetchFeedPosts(followerId, currentUserName: currentUserName, currentUserPhotoUrl: currentUserPhotoUrl);
      }
      return success;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String followerId, String followingId, {String? currentUserName, String? currentUserPhotoUrl}) async {
    try {
      final success = await _socialMediaService.unfollowUser(followerId, followingId);
      if (success) {
        _followingStatus[followingId] = false;
        Future.microtask(() => notifyListeners());
        // Refresh the feed posts for the follower to remove posts from unfollowed user
        await fetchFeedPosts(followerId, currentUserName: currentUserName, currentUserPhotoUrl: currentUserPhotoUrl);
      }
      return success;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  // Bookmark methods
  
      Future<bool> toggleBookmark(String postId, String userId) async {
    try {
      final newBookmarkStatus = await _socialMediaService.toggleBookmark(postId, userId);
      notifyListeners();
      return newBookmarkStatus;
    } catch (e) {
      print('Error toggling bookmark: $e');
      rethrow;
    }
  }

      Future<bool> isPostBookmarked(String postId, String userId) async {
    try {
      return await _socialMediaService.isPostBookmarked(postId, userId);
    } catch (e) {
      print('Error checking bookmark status: $e');
      return false;
    }
  }

  // Post views
  
  Future<void> recordPostView(String postId, {String? userId}) async {
    try {
      await _socialMediaService.recordPostView(postId, userId: userId);
    } catch (e) {
      print('Error recording post view: $e');
    }
  }
}
