import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_media_provider.dart';
import '../providers/auth_provider.dart';
import '../core/models/post_model.dart';
import '../core/models/user_model.dart' as app_user;
import '../common/colo_extension.dart';
import 'widgets/post_card_widget.dart';
import 'post_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Post>> _userPostsFuture;
  app_user.User? _profileUser;
  bool _isLoading = true;
  String? _error;
  bool _isRefreshing = false;
  bool _isFollowing = false;
  StreamSubscription? _postsSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeUpdates();
    _loadProfileData();
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeUpdates() {
    // Set up a periodic refresh to simulate real-time updates
    _postsSubscription =
        Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted && !_isRefreshing) {
        _refreshProfileData();
      }
    });
  }

  Future<void> _loadProfileData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socialProvider =
          Provider.of<SocialMediaProvider>(context, listen: false);

      // Get user data - either current user or fetch from social provider
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.id == widget.userId) {
        _profileUser = authProvider.currentUser;
      } else {
        // For other users, fetch their data from the service
        _profileUser = await _fetchUserData(widget.userId);
      }

      // Load user posts with enhanced error handling
      _userPostsFuture = _fetchUserPostsWithRetry(socialProvider);

      // If this is not the current user, check following status
      final currentUser = Supabase.instance.client.auth.currentUser;
      final currentUserId = currentUser?.id ?? '';
      if (widget.userId != currentUserId && currentUserId.isNotEmpty) {
        await socialProvider.checkFollowingStatus(currentUserId, [widget.userId]);
        setState(() {
          _isFollowing = socialProvider.followingStatus[widget.userId] ?? false;
        });
      }

      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<app_user.User?> _fetchUserData(String userId) async {
    try {
      // In a real app, this would fetch from your API
      // For now, we'll create a mock user with better data
      return app_user.User(
        id: userId,
        name: 'User $userId',
        username: 'user$userId',
        photoUrl: 'https://via.placeholder.com/150',
        profileData: const {
          'bio': 'Fitness enthusiast sharing workout journey',
          'location': 'Cairo, Egypt',
          'joined_date': '2023-01-01T00:00:00.000Z',
        },
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Post>> _fetchUserPostsWithRetry(
      SocialMediaProvider socialProvider) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 1);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final posts = await _fetchUserPosts(socialProvider);

        // If we have posts, return them
        if (posts.isNotEmpty) {
          return posts;
        }

        // If no posts and this is the last attempt, return empty list
        if (attempt == maxRetries) {
          return [];
        }

        // Wait before retrying
        await Future.delayed(retryDelay * attempt);
      } catch (e) {
        if (attempt == maxRetries) {
          rethrow;
        }
        // Wait before retrying
        await Future.delayed(retryDelay * attempt);
      }
    }

    return [];
  }

  Future<List<Post>> _fetchUserPosts(SocialMediaProvider socialProvider) async {
    try {
      // Filter posts by user ID from the existing feed
      final posts = socialProvider.feedPosts
          .where((post) => post.userId == widget.userId)
          .toList();

      // If no posts in feed, try to fetch from service
      if (posts.isEmpty) {
        await socialProvider.fetchUserPosts(widget.userId);
        return socialProvider.feedPosts
            .where((post) => post.userId == widget.userId)
            .toList();
      }

      return posts;
    } catch (e) {
      return [];
    }
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _error = null;
    });

    try {
      await _loadProfileData();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _refreshProfileData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final socialProvider =
          Provider.of<SocialMediaProvider>(context, listen: false);

      // Update user data if it's the current user
      if (authProvider.currentUser != null &&
          authProvider.currentUser!.id == widget.userId) {
        _profileUser = authProvider.currentUser;
      }

      // Refresh posts
      final posts = await _fetchUserPostsWithRetry(socialProvider);

      if (mounted) {
        setState(() {
          _userPostsFuture = Future.value(posts);
        });
      }
    } catch (e) {
      // Handle refresh error silently
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return 'حدث خطأ في تحميل البيانات. يرجى المحاولة مرة أخرى.';
    } else {
      return 'تعذر تحميل البيانات. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        Provider.of<AuthProvider>(context).currentUser?.id == widget.userId;

    return Scaffold(
        appBar: AppBar(
          title: Text(isCurrentUser ? 'My Profile' : 'User Profile'),
          backgroundColor: TColor.primaryColor1,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (isCurrentUser)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Implement edit profile
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit profile coming soon!')),
                  );
                },
              ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // Responsive design adjustments
          final isTablet = constraints.maxWidth > 600;
          final horizontalPadding = isTablet ? 24.0 : 16.0;
          final maxContentWidth = isTablet ? 600.0 : double.infinity;

          return _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xff92A3FD)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'جاري تحميل البيانات...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _error != null
                  ? Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[400],
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _refreshProfile,
                              icon: const Icon(Icons.refresh),
                              label: const Text('حاول مرة أخرى'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: TColor.primaryColor1,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _refreshProfile();
                      },
                      color: TColor.primaryColor1,
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                      child: CustomScrollView(
                        slivers: [
                          // Profile Header
                          SliverToBoxAdapter(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth > 600;
                                final horizontalPadding =
                                    isTablet ? 32.0 : 24.0;

                                return Container(
                                  padding: EdgeInsets.all(horizontalPadding),
                                  child: _buildProfileHeader(),
                                );
                              },
                            ),
                          ),

                          // Stats Section
                          FutureBuilder<List<Post>>(
                            future: _userPostsFuture,
                            builder: (context, snapshot) {
                              final postCount = snapshot.hasData
                                  ? snapshot.data!.length.toString()
                                  : '0';
                              return SliverToBoxAdapter(
                                child: _buildStatsSection(postCount),
                              );
                            },
                          ),

                          // User Posts
                          FutureBuilder<List<Post>>(
                            future: _userPostsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xff92A3FD)),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'جاري تحميل المنشورات...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[400],
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'تعذر تحميل المنشورات',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'حدث خطأ أثناء جلب المنشورات. يرجى المحاولة مرة أخرى.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton.icon(
                                            onPressed: _refreshProfile,
                                            icon: const Icon(Icons.refresh,
                                                size: 20),
                                            label: const Text('إعادة المحاولة'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  TColor.primaryColor1,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return SliverFillRemaining(
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.post_add,
                                            color: Colors.grey[400],
                                            size: 64,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'لا توجد منشورات',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            isCurrentUser
                                                ? 'شارك أول منشور لك لتبدأ رحلتك!'
                                                : 'لم ينشر هذا المستخدم أي شيء بعد.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          if (isCurrentUser) ...[
                                            const SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // Navigate to create post
                                                Navigator.pushNamed(
                                                    context, '/create_post');
                                              },
                                              icon: const Icon(Icons.add,
                                                  size: 20),
                                              label: const Text('إنشاء منشور'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    TColor.primaryColor1,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final posts = snapshot.data!;
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final post = posts[index];
                                    return PostCardWidget(
                                      post: post,
                                      onLike: () {
                                        // Like functionality
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Liked post'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      onComment: () {
                                        // Navigate to PostDetailScreen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PostDetailScreen(post: post),
                                          ),
                                        );
                                      },
                                      onShare: () {
                                        // Share post logic
                                        _sharePost(post);
                                      },
                                    );
                                  },
                                  childCount: posts.length,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
        }));
  }

  Future<void> _pickImage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.currentUser?.id != widget.userId) {
      return; // Only allow current user to change their own profile image
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? photo =
                      await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    await _updateProfileImage(File(photo.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    await _updateProfileImage(File(image.path));
                  }
                },
              ),
              if (_profileUser?.photoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo',
                      style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await _removeProfileImage();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateProfileImage(File imageFile) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        _isLoading = true;
      });

      final success = await authProvider.updateProfileImage(imageFile);

      if (success) {
        // Update local profile user
        if (mounted) {
          setState(() {
            _profileUser = authProvider.currentUser;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      setState(() {
        _isLoading = true;
      });

      // Update user with null photo URL
      final updatedUser = authProvider.currentUser!.copyWith(
        photoUrl: null,
        avatarUrl: null,
      );

      final success = await authProvider.updateUserProfile(
        name: updatedUser.name,
        username: updatedUser.username,
        profileData: updatedUser.profileData,
      );

      if (success) {
        if (mounted) {
          setState(() {
            _profileUser = authProvider.currentUser;
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image removed successfully!')),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove profile image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildProfileHeader() {
    final isCurrentUser =
        Provider.of<AuthProvider>(context).currentUser?.id == widget.userId;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColor.primaryColor1.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: isCurrentUser ? _pickImage : null,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: TColor.primaryColor1, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileUser?.photoUrl != null
                        ? CachedNetworkImageProvider(_profileUser!.photoUrl!)
                        : null,
                    child: _profileUser?.photoUrl == null
                        ? Text(
                            _profileUser?.name?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                ),
                if (isCurrentUser)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor1,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            _profileUser?.name ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Username
          Text(
            '@${_profileUser?.username ?? 'user${widget.userId}'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Bio/Description (if available)
          if (_profileUser?.profileData?['bio'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _profileUser!.profileData!['bio'],
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          // Follow button for other users
          if (!isCurrentUser)
            const SizedBox(height: 16),
          if (!isCurrentUser)
            ElevatedButton(
              onPressed: () async {
                final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
                final currentUser = Supabase.instance.client.auth.currentUser;
                final currentUserId = currentUser?.id ?? '';
                if (currentUserId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login to follow users')),
                  );
                  return;
                }

                setState(() {
                  _isLoading = true;
                });

                bool success;
                if (_isFollowing) {
                  success = await socialProvider.unfollowUser(
                    currentUserId, 
                    widget.userId,
                    currentUserName: currentUser?.userMetadata?['username'],
                    currentUserPhotoUrl: currentUser?.userMetadata?['avatar_url'],
                  );
                } else {
                  success = await socialProvider.followUser(
                    currentUserId, 
                    widget.userId,
                    currentUserName: currentUser?.userMetadata?['username'],
                    currentUserPhotoUrl: currentUser?.userMetadata?['avatar_url'],
                  );
                }

                if (success) {
                  setState(() {
                    _isFollowing = !_isFollowing;
                  });
                  
                  // Show feedback message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isFollowing ? 'Followed successfully!' : 'Unfollowed successfully!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong. Please try again.')),
                  );
                }

                setState(() {
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[400] : Theme.of(context).primaryColor,
                foregroundColor: _isFollowing ? Colors.black87 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(String postCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Posts', postCount),
          _buildStatItem('Followers', '0'),
          _buildStatItem('Following', '0'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _sharePost(Post post) {
    final shareText = '''Check out this post by ${post.userName}:
${post.content}

Shared from Fitness App'''
        .trim();

    debugPrint('Sharing post: $shareText');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Sharing: ${post.content.substring(0, post.content.length > 50 ? 50 : post.content.length)}${post.content.length > 50 ? '...' : ''}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
