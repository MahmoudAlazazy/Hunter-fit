import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_media_provider.dart';
import '../core/models/post_model.dart';
import 'friend_requests_screen.dart';
import 'post_detail_screen.dart';
import 'widgets/post_creation_widget.dart';
import 'widgets/post_card_widget.dart';

class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({Key? key}) : super(key: key);

  @override
  State<SocialMediaPage> createState() => _SocialMediaPageState();
}

class _SocialMediaPageState extends State<SocialMediaPage> {
  late Future<void> _postsFuture;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    final currentUserName = user?.userMetadata?['username'] ?? user?.email?.split('@')[0];
    final currentUserPhotoUrl = user?.userMetadata?['avatar_url'];
    final currentUserId = user?.id ?? '';
    
    // Initialize with a completed future first
    _postsFuture = Future.value();
    
    // Schedule the initial data load after the first frame to avoid
    // notifyListeners() being called during widget build which throws.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _postsFuture = Provider.of<SocialMediaProvider>(context, listen: false).fetchFeedPosts(
        currentUserId,
        currentUserName: currentUserName,
        currentUserPhotoUrl: currentUserPhotoUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Media'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendRequestsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<void>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                PostCreationWidget(
                  onPostCreated: (content, imagePaths, videoPath) async {
                    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
                    final user = Supabase.instance.client.auth.currentUser;
                    
                    if (user != null) {
                      // Use the first image if available, otherwise null
                      final imagePath = imagePaths.isNotEmpty ? imagePaths.first : null;
                      
                      await socialProvider.createPost(
                        userId: user.id,
                        content: content,
                        imagePath: imagePath,
                        userName: user.userMetadata?['username'] ?? user.email?.split('@')[0],
                        userPhotoUrl: user.userMetadata?['avatar_url'],
                      );
                      
                      // Refresh posts after creating new post
                      if (mounted) {
                        final currentUserName = user.userMetadata?['username'] ?? user.email?.split('@')[0];
                        final currentUserPhotoUrl = user.userMetadata?['avatar_url'];
                        final currentUserId = user.id;
                        await socialProvider.fetchFeedPosts(
                          currentUserId,
                          currentUserName: currentUserName,
                          currentUserPhotoUrl: currentUserPhotoUrl,
                        );
                      }
                    }
                  },
                ),
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          } else if (snapshot.hasError) {
            return Column(
              children: [
                PostCreationWidget(
                  onPostCreated: (content, imagePaths, videoPath) async {
                    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
                    final user = Supabase.instance.client.auth.currentUser;
                    
                    if (user != null) {
                      // Use the first image if available, otherwise null
                      final imagePath = imagePaths.isNotEmpty ? imagePaths.first : null;
                      
                      await socialProvider.createPost(
                        userId: user.id,
                        content: content,
                        imagePath: imagePath,
                        userName: user.userMetadata?['username'] ?? user.email?.split('@')[0],
                        userPhotoUrl: user.userMetadata?['avatar_url'],
                      );
                      
                      // Refresh posts after creating new post
                      if (mounted) {
                        final currentUserName = user.userMetadata?['username'] ?? user.email?.split('@')[0];
                        final currentUserPhotoUrl = user.userMetadata?['avatar_url'];
                        final currentUserId = user.id;
                        await socialProvider.fetchFeedPosts(
                          currentUserId,
                          currentUserName: currentUserName,
                          currentUserPhotoUrl: currentUserPhotoUrl,
                        );
                      }
                    }
                  },
                ),
                Expanded(child: Center(child: Text('Error: ${snapshot.error}'))),
              ],
            );
          }

          final socialProvider = Provider.of<SocialMediaProvider>(context);
          final posts = socialProvider.feedPosts;

          return Column(
            children: [
              // Facebook-style post creation at the top
              PostCreationWidget(
                onPostCreated: (content, imagePaths, videoPath) async {
                  final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
                  final user = Supabase.instance.client.auth.currentUser;
                  
                  if (user != null) {
                    // Use the first image if available, otherwise null
                    final imagePath = imagePaths.isNotEmpty ? imagePaths.first : null;
                    
                    await socialProvider.createPost(
                      userId: user.id,
                      content: content,
                      imagePath: imagePath,
                      userName: user.userMetadata?['username'] ?? user.email?.split('@')[0],
                      userPhotoUrl: user.userMetadata?['avatar_url'],
                    );
                    
                    // Refresh posts after creating new post
                    if (mounted) {
                      final currentUserName = user.userMetadata?['username'] ?? user.email?.split('@')[0];
                      final currentUserPhotoUrl = user.userMetadata?['avatar_url'];
                      final currentUserId = user.id;
                      await socialProvider.fetchFeedPosts(
                        currentUserId,
                        currentUserName: currentUserName,
                        currentUserPhotoUrl: currentUserPhotoUrl,
                      );
                    }
                  }
                },
              ),
              
              // Posts list
              if (posts.isEmpty)
                const Expanded(
                  child: Center(child: Text('No posts available. Be the first to share something!')),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final user = Supabase.instance.client.auth.currentUser;
                      final currentUserName = user?.userMetadata?['username'] ?? user?.email?.split('@')[0];
                      final currentUserPhotoUrl = user?.userMetadata?['avatar_url'];
                      final currentUserId = user?.id ?? '';
                      await socialProvider.fetchFeedPosts(
                        currentUserId,
                        currentUserName: currentUserName,
                        currentUserPhotoUrl: currentUserPhotoUrl,
                      );
                    },
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return PostCardWidget(
                          post: post,
                          onLike: () {
                            // Like functionality will be handled by the PostCardWidget itself
                            // This is just a callback for any additional logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Liked post by ${post.userName}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onComment: () {
                            // Navigate to comments page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(post: post),
                              ),
                            );
                          },
                          onShare: () {
                            // Share post logic
                            _sharePost(post);
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _sharePost(Post post) {
    // Share post logic
    final shareText = '''Check out this post by ${post.userName}:
${post.content}

Shared from Fitness App'''.trim();

    // Use the shareText for actual sharing functionality
    debugPrint('Sharing post: $shareText');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${post.content.substring(0, post.content.length > 50 ? 50 : post.content.length)}${post.content.length > 50 ? '...' : ''}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
