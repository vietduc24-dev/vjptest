import 'package:flutter/material.dart';
import '../../../services/api/friends/friends_load/list_friends.dart';

class FriendItem extends StatelessWidget {
  final Friend friend;

  const FriendItem({
    super.key,
    required this.friend,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: friend.avatar != null ? NetworkImage(friend.avatar!) : null,
        child: friend.avatar == null ? Text(friend.username[0].toUpperCase()) : null,
      ),
      title: Text(friend.fullName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(friend.username),
          Text(friend.status ?? 'Offline', 
            style: TextStyle(
              color: friend.status == 'Online' ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // TODO: Implement chat
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
        ],
      ),
    );
  }
} 