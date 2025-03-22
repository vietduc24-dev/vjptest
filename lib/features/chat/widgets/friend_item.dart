import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_router.dart';
import '../../../services/api/friends/friends_load/list_friends.dart';
import '../../../services/api/authentication/auth_service.dart';
import '../../../services/api/api_provider.dart';

class FriendItem extends StatelessWidget {
  final Friend friend;

  const FriendItem({
    super.key,
    required this.friend,
  });

  void _openChat(BuildContext context) async {
    final authService = context.read<AuthService>();
    final currentUserId = await authService.getUsername();
    
    if (currentUserId == null) {
      // Handle error - user not logged in
      return;
    }

    AppRouter.goToChat(context, friend, currentUserId);
  }

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
            onPressed: () => _openChat(context),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
        ],
      ),
      onTap: () => _openChat(context),
    );
  }
} 