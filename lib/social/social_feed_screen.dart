import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_media_provider.dart';
import '../core/models/post_model.dart';
import 'post_detail_screen.dart';
import 'profile_screen.dart';
import 'social_media_page.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({Key? key}) : super(key: key);

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUserData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more posts when reaching the bottom
      _loadMorePosts();
    }
  }

  // Helper methods for enhanced sharing
  Future<bool> _handleExternalSharing({
    required Post post,
    required String content,
    String? platform,
  }) async {
    try {
      String shareText = '';
      if (content.isNotEmpty) {
        shareText = '$content\n\n';
      }
      shareText += '"${post.content}"\n- ${post.userName ?? 'Unknown User'}';
      
      if (post.tags != null && post.tags!.isNotEmpty) {
        shareText += '\n\n${post.tags!.map((tag) => '#$tag').join(' ')}';
      }

      // In a real app, you would integrate with platform-specific sharing
      // The shareText variable contains the formatted content to share
      // For now, we'll simulate the sharing
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Show platform-specific message
      if (platform != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Shared to $platform successfully!')),
        );
      }
      
      return true;
    } catch (e) {
      debugPrint('Error in external sharing: $e');
      return false;
    }
  }

  Future<void> _shareWithSpecificFriends({
    required Post post,
    required List<String> friends,
    required String content,
  }) async {
    // In a real app, this would create private shares for specific friends
    // For now, we'll simulate the friend-specific sharing
    for (final friendId in friends) {
      debugPrint('Sharing post ${post.id} with friend: $friendId');
    }
  }

  Future<void> _shareWithSpecificGroups({
    required Post post,
    required List<String> groups,
    required String content,
  }) async {
    // In a real app, this would create shares for specific groups
    // For now, we'll simulate the group-specific sharing
    for (final groupId in groups) {
      debugPrint('Sharing post ${post.id} with group: $groupId');
    }
  }

  String _getSuccessMessage(String shareType) {
    switch (shareType) {
      case 'public':
        return 'Post shared publicly!';
      case 'friends':
        return 'Post shared with friends!';
      case 'groups':
        return 'Post shared with groups!';
      case 'private':
        return 'Post saved privately!';
      case 'external':
        return 'Post shared externally!';
      default:
        return 'Post shared successfully!';
    }
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
      _loadFeed();
    } else {
      // Show login prompt or guest mode
      setState(() {
        _currentUserId = '';
      });
      _loadGuestFeed();
    }
  }

  void _loadFeed() {
    if (_currentUserId.isNotEmpty) {
      final user = Supabase.instance.client.auth.currentUser;
      final currentUserName = user?.userMetadata?['username'] ?? user?.email?.split('@')[0];
      final currentUserPhotoUrl = user?.userMetadata?['avatar_url'];
      
      final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
      socialProvider.fetchFeedPosts(
        _currentUserId,
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    }
  }

  void _loadGuestFeed() {
    // Load public posts for non-logged in users
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    socialProvider.fetchFeedPosts(''); // Use empty string for guest users
  }

  void _loadMorePosts() {
    // Implement pagination here
    // For now, just refresh the feed
    _loadFeed();
  }

  void _refreshFeed() {
    _loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUserId.isNotEmpty ? 'Social Feed' : 'Social Feed (Guest)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_currentUserId.isEmpty)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                // Navigate to login screen
                Navigator.pushNamed(context, '/login');
              },
              tooltip: 'Login',
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              if (_currentUserId.isNotEmpty) {
                Navigator.pushNamed(context, '/notifications');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login to view notifications')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              if (_currentUserId.isNotEmpty) {
                Navigator.pushNamed(context, '/bookmarks');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please login to view bookmarks')),
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<SocialMediaProvider>(
        builder: (context, socialProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              _refreshFeed();
            },
            child: socialProvider.isLoadingPosts && socialProvider.feedPosts.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : socialProvider.postsError != null
                    ? _buildErrorWidget(socialProvider.postsError!)
                    : socialProvider.feedPosts.isEmpty
                        ? _buildEmptyWidget()
                        : _buildFeedList(socialProvider),
          );
        },
      ),
      floatingActionButton: null, // Post creation centralized to SocialMediaPage
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red[400], size: 64),
          const SizedBox(height: 16),
          Text(
            'Error loading feed',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshFeed,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    if (_currentUserId.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, color: Colors.grey[400], size: 64),
            const SizedBox(height: 16),
            Text(
              'Login to see posts',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an account to share your fitness journey',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.feed, color: Colors.grey[400], size: 64),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SocialMediaPage()),
              ).then((_) => _loadFeed());
            },
            child: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(SocialMediaProvider socialProvider) {
    // Responsive design based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1200;
    
    final horizontalPadding = isDesktop ? 16.0 : (isTablet ? 12.0 : 8.0);
    final verticalPadding = isDesktop ? 12.0 : (isTablet ? 10.0 : 8.0);
    
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      itemCount: socialProvider.feedPosts.length + (socialProvider.isLoadingPosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= socialProvider.feedPosts.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = socialProvider.feedPosts[index];
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PostCard(
              post: post,
              currentUserId: _currentUserId,
              onLike: () => _toggleLike(post.id!),
              onComment: () => _navigateToPostDetail(post),
              onShare: () => _sharePost(post),
              onBookmark: () => _toggleBookmark(post.id!),
              onUserTap: () => _navigateToProfile(post.userId),
              onDelete: post.userId == _currentUserId ? () => _deletePost(post.id!) : null,
            ),
          ),
        );
      },
    );
  }

  void _toggleLike(String postId) async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    await socialProvider.toggleLike(_currentUserId, postId: postId);
  }

  void _toggleBookmark(String postId) async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    await socialProvider.toggleBookmark(postId, _currentUserId);
  }

  void _sharePost(Post post) async {
    final user = Supabase.instance.client.auth.currentUser;
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    
    if (_currentUserId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to share posts')),
        );
      }
      return;
    }

    // Show share dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SharePostDialog(post: post),
    );

    if (result != null) {
      final shareType = result['shareType'] ?? 'public';
      final selectedFriends = result['selectedFriends'] ?? [];
      final selectedGroups = result['selectedGroups'] ?? [];
      
      // Handle different sharing types
      bool success = false;
      
      if (shareType == 'external') {
        // Handle external sharing
        final externalPlatform = result['externalPlatform'];
        success = await _handleExternalSharing(
          post: post,
          content: result['content'] ?? '',
          platform: externalPlatform,
        );
      } else {
        // Handle internal sharing
        success = await socialProvider.sharePost(
          originalPostId: post.id!,
          sharedByUserId: _currentUserId,
          sharedContent: result['content'] ?? '',
          isPublic: shareType == 'public',
          userName: user?.userMetadata?['username'],
          userPhotoUrl: user?.userMetadata?['avatar_url'],
        );
        
        // Handle friend-specific sharing
        if (shareType == 'friends' && selectedFriends.isNotEmpty) {
          await _shareWithSpecificFriends(
            post: post,
            friends: selectedFriends,
            content: result['content'] ?? '',
          );
        }
        
        // Handle group-specific sharing
        if (shareType == 'groups' && selectedGroups.isNotEmpty) {
          await _shareWithSpecificGroups(
            post: post,
            groups: selectedGroups,
            content: result['content'] ?? '',
          );
        }
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_getSuccessMessage(shareType))),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to share post')),
          );
        }
      }
    }
  }

  void _navigateToPostDetail(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );
  }

  void _navigateToProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen(userId: userId)),
    );
  }

  void _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
      final success = await socialProvider.deletePost(postId, _currentUserId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete post')),
          );
        }
      }
    }
  }
}

class SharePostDialog extends StatefulWidget {
  final Post post;

  const SharePostDialog({Key? key, required this.post}) : super(key: key);

  @override
  State<SharePostDialog> createState() => _SharePostDialogState();
}

class _SharePostDialogState extends State<SharePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  String _shareType = 'public'; // public, private, friends, groups, external
  final List<String> _selectedFriends = [];
  final List<String> _selectedGroups = [];

  // External sharing options
  final List<Map<String, dynamic>> _externalPlatforms = [
    {'name': 'WhatsApp', 'icon': Icons.message, 'color': Colors.green},
    {'name': 'Facebook', 'icon': Icons.facebook, 'color': Colors.blue},
    {'name': 'Twitter', 'icon': Icons.link, 'color': Colors.lightBlue},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'color': Colors.purple},
    {'name': 'Email', 'icon': Icons.email, 'color': Colors.red},
    {'name': 'Copy Link', 'icon': Icons.content_copy, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Share Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add your thoughts (optional):'),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'What do you think about this?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Share to:'),
            const SizedBox(height: 8),
            // Share type selection
            _buildShareTypeSelector(),
            const SizedBox(height: 16),
            // Conditional sections based on share type
            if (_shareType == 'friends') _buildFriendSelector(),
            if (_shareType == 'groups') _buildGroupSelector(),
            if (_shareType == 'external') _buildExternalSharing(),
            const SizedBox(height: 16),
            // Post preview
            const Text('Post Preview:'),
            const SizedBox(height: 8),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: widget.post.userPhotoUrl != null
                            ? CachedNetworkImageProvider(widget.post.userPhotoUrl!)
                            : null,
                        child: widget.post.userPhotoUrl == null
                            ? Text(widget.post.userName?.substring(0, 1).toUpperCase() ?? 'U')
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.post.userName ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.post.content),
                  if (widget.post.tags != null && widget.post.tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: widget.post.tags!.map((tag) => 
                        Text('#$tag ', style: TextStyle(color: Colors.blue[700], fontSize: 12))
                      ).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'content': _contentController.text.trim(),
              'shareType': _shareType,
              'selectedFriends': _selectedFriends,
              'selectedGroups': _selectedGroups,
            });
          },
          child: const Text('Share'),
        ),
      ],
    );
  }

  Widget _buildShareTypeSelector() {
    return Column(
      children: [
        _buildShareTypeOption('public', Icons.public, 'Public', 'Share with everyone'),
        _buildShareTypeOption('friends', Icons.people, 'Friends', 'Share with your friends'),
        _buildShareTypeOption('groups', Icons.groups, 'Groups', 'Share with specific groups'),
        _buildShareTypeOption('private', Icons.lock, 'Private', 'Only you can see'),
        _buildShareTypeOption('external', Icons.share, 'External', 'Share on other platforms'),
      ],
    );
  }

  Widget _buildShareTypeOption(String value, IconData icon, String title, String subtitle) {
    return RadioListTile<String>(
      value: value,
      groupValue: _shareType,
      onChanged: (value) {
        setState(() {
          _shareType = value!;
        });
      },
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: Icon(icon, color: Theme.of(context).primaryColor),
      dense: true,
    );
  }

  Widget _buildFriendSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Select Friends:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Mock friend list - in real app, this would come from your friends service
        _buildFriendCheckbox('John Doe', 'john_doe'),
        _buildFriendCheckbox('Jane Smith', 'jane_smith'),
        _buildFriendCheckbox('Mike Johnson', 'mike_johnson'),
        _buildFriendCheckbox('Sarah Wilson', 'sarah_wilson'),
      ],
    );
  }

  Widget _buildFriendCheckbox(String name, String id) {
    return CheckboxListTile(
      title: Text(name),
      value: _selectedFriends.contains(id),
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _selectedFriends.add(id);
          } else {
            _selectedFriends.remove(id);
          }
        });
      },
      dense: true,
    );
  }

  Widget _buildGroupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Select Groups:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Mock group list - in real app, this would come from your groups service
        _buildGroupCheckbox('Fitness Enthusiasts', 'fitness_group'),
        _buildGroupCheckbox('Workout Buddies', 'workout_group'),
        _buildGroupCheckbox('Healthy Lifestyle', 'health_group'),
        _buildGroupCheckbox('Running Club', 'running_group'),
      ],
    );
  }

  Widget _buildGroupCheckbox(String name, String id) {
    return CheckboxListTile(
      title: Text(name),
      value: _selectedGroups.contains(id),
      onChanged: (checked) {
        setState(() {
          if (checked == true) {
            _selectedGroups.add(id);
          } else {
            _selectedGroups.remove(id);
          }
        });
      },
      dense: true,
    );
  }

  Widget _buildExternalSharing() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Share on:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _externalPlatforms.length,
          itemBuilder: (context, index) {
            final platform = _externalPlatforms[index];
            return InkWell(
              onTap: () {
                 // Handle external sharing - pass platform name back
                 Navigator.pop(context, {
                   'content': _contentController.text.trim(),
                   'shareType': 'external',
                   'externalPlatform': platform['name'],
                 });
               },
              child: Container(
                decoration: BoxDecoration(
                  color: (platform['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: platform['color']),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(platform['icon'], color: platform['color'], size: 24),
                    const SizedBox(height: 4),
                    Text(
                      platform['name'],
                      style: TextStyle(
                        color: platform['color'],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final VoidCallback onUserTap;
  final VoidCallback? onDelete;

  const PostCard({
    Key? key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onBookmark,
    required this.onUserTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialMediaProvider>(
      builder: (context, socialProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, socialProvider, onDelete),
              if (post.content.isNotEmpty) _buildContent(context),
              if (post.imagePath != null) _buildImage(),
              _buildActions(context, socialProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SocialMediaProvider socialProvider, VoidCallback? onDelete) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // User avatar
          InkWell(
            onTap: onUserTap,
            borderRadius: BorderRadius.circular(25),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: post.userPhotoUrl != null
                  ? CachedNetworkImageProvider(post.userPhotoUrl!)
                  : null,
              child: post.userPhotoUrl == null
                  ? Text(
                      post.userName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userName ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[600], size: 18),
                      const SizedBox(width: 8),
                      Text('Delete Post', style: TextStyle(color: Colors.red[600])),
                    ],
                  ),
                ),
              ],
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        post.content,
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        post.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context, SocialMediaProvider socialProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Like button
          FutureBuilder<bool>(
            future: socialProvider.isLikedByUser(currentUserId, postId: post.id),
            builder: (context, snapshot) {
              final isLiked = snapshot.data ?? false;
              return IconButton(
                onPressed: onLike,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : Colors.grey[600],
                  size: 24,
                ),
              );
            },
          ),
          // Comment button
          IconButton(
            onPressed: onComment,
            icon: Icon(
              Icons.comment_outlined,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          // Share button
          IconButton(
            onPressed: onShare,
            icon: Icon(
              Icons.share_outlined,
              color: Colors.grey[600],
              size: 24,
            ),
          ),
          const Spacer(),
          // Bookmark button
          FutureBuilder<bool>(
            future: socialProvider.isPostBookmarked(post.id!, currentUserId),
            builder: (context, snapshot) {
              final isBookmarked = snapshot.data ?? false;
              return IconButton(
                onPressed: onBookmark,
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.grey[600] : Colors.grey[600],
                  size: 24,
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
