import 'package:flutter/material.dart';
import '../../../services/api/friends/friends_load/list_friends.dart';

class FriendRequestItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestItem({
    super.key,
    required this.friend,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.avatar != null ? NetworkImage(friend.avatar!) : null,
        child: friend.avatar == null ? Text(friend.username[0].toUpperCase()) : null,
      ),
      title: Text(friend.fullName),
      subtitle: Text(friend.username),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: onAccept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onReject,
          ),
        ],
      ),
    );
  }
} 