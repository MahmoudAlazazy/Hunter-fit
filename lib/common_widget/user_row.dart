import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar_url'] != null
              ? NetworkImage(user['avatar_url'])
              : null,
          child: user['avatar_url'] == null
              ? Text(user['username']?.substring(0, 1).toUpperCase() ?? 'U')
              : null,
        ),
        title: Text(user['username'] ?? 'Unknown User'),
        subtitle: Text(user['email'] ?? ''),
        trailing: ElevatedButton(
          onPressed: onFollowPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 30),
          ),
          child: Text(isFollowing ? 'Following' : 'Follow'),
        ),
      ),
    );
  }
}