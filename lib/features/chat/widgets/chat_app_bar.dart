import 'package:flutter/material.dart';
import '../../../services/api/friends/friends_load/list_friends.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Friend friend;
  final VoidCallback onBackPressed;

  const ChatAppBar({
    super.key,
    required this.friend,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Colors.blue[700],
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackPressed,
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: friend.avatar != null
                  ? NetworkImage(friend.avatar!)
                  : null,
              backgroundColor: Colors.blue[300],
              child: friend.avatar == null
                  ? Text(
                      friend.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    friend.status ?? 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: friend.status == 'Online'
                          ? Colors.greenAccent
                          : Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 