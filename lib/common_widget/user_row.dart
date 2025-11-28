import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isFollowing;
  final VoidCallback onFollowPressed;

  const UserRow({
    Key? key,
    required this.user,
    required this.isFollowing,
    required this.onFollowPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 23,
                backgroundImage: user['avatar_url'] != null && user['avatar_url'].isNotEmpty
                    ? CachedNetworkImageProvider(user['avatar_url'])
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: user['avatar_url'] == null || user['avatar_url'].isEmpty
                    ? Text(
                        user['username']?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['username'] ?? 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['email'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Follow Button
            ElevatedButton(
              onPressed: onFollowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey.shade400 : Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 1,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}