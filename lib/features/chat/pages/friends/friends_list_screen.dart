import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../cubit/friends/firends_cubit.dart';
import '../../cubit/friends/firends_state.dart';
import '../../widgets/friend_request_item.dart';
import '../../widgets/friend_item.dart';

class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Friends'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  // TODO: Implement add friend dialog
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<FriendsCubit>().loadFriends(refresh: true),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FriendsState state) {
    if (state is FriendsInitial) {
      // Load friends when screen is first opened
      context.read<FriendsCubit>().loadFriends();
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsLoading && state.isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<FriendsCubit>().loadFriends(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is FriendsLoaded) {
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter == 0 &&
              state.friends.hasMore &&
              !(state is FriendsLoading && (state as FriendsLoading).isLoadingMore)) {
            context.read<FriendsCubit>().loadMoreFriends();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            if (state.friendRequests.items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Friend Requests (${state.friendRequests.items.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            if (state.friendRequests.items.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final request = state.friendRequests.items[index];
                    return FriendRequestItem(
                      friend: request,
                      onAccept: () => context.read<FriendsCubit>().acceptFriendRequest(request.username),
                      onReject: () => context.read<FriendsCubit>().rejectFriendRequest(request.username),
                    );
                  },
                  childCount: state.friendRequests.items.length,
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Friends (${state.friends.items.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final friend = state.friends.items[index];
                  return FriendItem(friend: friend);
                },
                childCount: state.friends.items.length,
              ),
            ),
            if (state is FriendsLoading && (state as FriendsLoading).isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }
} 