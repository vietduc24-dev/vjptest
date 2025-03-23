import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../cubit/friends/firends_cubit.dart';
import '../../cubit/friends/firends_state.dart';
import '../../widgets/friend_request_item.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Lời mời kết bạn'),
          ),
          body: SafeArea(
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FriendsState state) {
    if (state is! FriendsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final requests = state.friendRequests.items;
    
    if (requests.isEmpty) {
      return const Center(
        child: Text('No friend requests'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return FriendRequestItem(
          friend: request,
          onAccept: () => context.read<FriendsCubit>().acceptFriendRequest(request.username),
          onReject: () => context.read<FriendsCubit>().rejectFriendRequest(request.username),
        );
      },
    );
  }
} 