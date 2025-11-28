import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_media_provider.dart';
import '../providers/auth_provider.dart';
import '../common_widget/user_row.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late Future<void> _dataFuture;
  Map<String, bool> _followingStatus = {};
  String _currentUserId = ''; // will be set to the current authenticated user id

  @override
  void initState() {
    super.initState();
    // Initialize with a completed future to prevent LateInitializationError
    _dataFuture = Future.value();
    // Schedule data loading after the first frame to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    final currentUser = Supabase.instance.client.auth.currentUser;
    _currentUserId = currentUser?.id ?? '';
    _dataFuture = socialProvider.getAllUsersWithProfiles().then((_) async {
      final userIds = socialProvider.users.map((u) => u.id!).toList();
      await socialProvider.checkFollowingStatus(_currentUserId, userIds);
      setState(() {
        _followingStatus = socialProvider.followingStatus;
      });
    });
  }

  Future<void> _toggleFollow(String userId, String followingId) async {
    final socialProvider =
        Provider.of<SocialMediaProvider>(context, listen: false);

    final currentUser = Supabase.instance.client.auth.currentUser;

    bool isCurrentlyFollowing = _followingStatus[followingId] ?? false;

    bool success;
    if (isCurrentlyFollowing) {
      success = await socialProvider.unfollowUser(
        userId,
        followingId,
        currentUserName: currentUser?.userMetadata?['username'],
        currentUserPhotoUrl: currentUser?.userMetadata?['avatar_url'],
      );
    } else {
      success = await socialProvider.followUser(
        userId,
        followingId,
        currentUserName: currentUser?.userMetadata?['username'],
        currentUserPhotoUrl: currentUser?.userMetadata?['avatar_url'],
      );
    }

    if (success) {
      setState(() {
        _followingStatus[followingId] = !isCurrentlyFollowing;
      });

      // Refresh feed so followed user's posts are included/excluded
      if (_currentUserId.isNotEmpty) {
        await socialProvider.fetchFeedPosts(_currentUserId);
      }
      // Refresh user list and follow statuses
      await socialProvider.getAllUsersWithProfiles();
      final userIds = socialProvider.users.map((u) => u.id!).toList();
      await socialProvider.checkFollowingStatus(_currentUserId, userIds);
      setState(() {
        _followingStatus = socialProvider.followingStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (Provider.of<SocialMediaProvider>(context).users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final provider = Provider.of<SocialMediaProvider>(context);
          final otherUsers = provider.users.where((user) => user.id != _currentUserId).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];
              final isFollowing = _followingStatus[user.id!] ?? false;

              return UserRow(
                user: {
                  'id': user.id,
                  'username': user.name,
                  'email': user.email,
                  'avatar_url': user.photoUrl,
                },
                isFollowing: isFollowing,
                onFollowPressed: () => _toggleFollow(_currentUserId, user.id!),
              );
            },
          );
        },
      ),
    );
  }
}
