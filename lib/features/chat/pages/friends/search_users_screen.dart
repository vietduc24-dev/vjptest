import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/bloc_status.dart';
import '../../../../common/widgets/loading_indicator.dart';
import '../../../../common/widgets/toast.dart';
import '../../cubit/friends/firends_cubit.dart';
import '../../cubit/friends/firends_state.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _searchController = TextEditingController();
  final _debounce = Debouncer(milliseconds: 500);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce.run(() {
      if (query.trim().isNotEmpty) {
        context.read<FriendsCubit>().searchUsers(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Tìm kiếm người dùng'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Nhập tên hoặc email để tìm kiếm',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<FriendsCubit, FriendsState>(
              listener: (context, state) {
                if (state.isSuccess && state.successMessage != null) {
                  Toast.show(
                    context,
                    state.successMessage!,
                    type: ToastType.success,
                  );
                } else if (state.hasError && state.errorMessage != null) {
                  Toast.show(
                    context,
                    state.errorMessage!,
                    type: ToastType.error,
                  );
                }
              },
              builder: (context, state) {
                if (state.status == BlocStatus.loading && !state.isLoadingMore) {
                  return const Center(child: LoadingIndicator());
                }
                
                if (state.hasError) {
                  return Center(child: Text(state.errorMessage!));
                }

                if (state.searchResults.isNotEmpty) {
                  return ListView.builder(
                    itemCount: state.searchResults.length,
                    itemBuilder: (context, index) {
                      final user = state.searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatar != null
                              ? NetworkImage(user.avatar!)
                              : null,
                          child: user.avatar == null
                              ? Text(user.fullName[0].toUpperCase())
                              : null,
                        ),
                        title: Text(user.fullName),
                        subtitle: Text(user.username),
                        trailing: _buildActionButton(context, user),
                      );
                    },
                  );
                }

                if (_searchController.text.isEmpty) {
                  return const Center(
                    child: Text('Nhập tên hoặc email để tìm kiếm người dùng'),
                  );
                }

                return const Center(
                  child: Text('Không tìm thấy người dùng nào'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Friend user) {
    switch (user.friendshipStatus) {
      case 'friend':
        return TextButton(
          onPressed: null,
          child: const Text('Bạn bè'),
        );
      case 'pending_sent':
        return TextButton(
          onPressed: null,
          child: const Text('Đã gửi lời mời'),
        );
      case 'pending_received':
        return TextButton(
          onPressed: () {
            context.read<FriendsCubit>().acceptFriendRequest(user.username);
          },
          child: const Text('Chấp nhận'),
        );
      case 'none':
      default:
        return TextButton(
          onPressed: () {
            context.read<FriendsCubit>().sendFriendRequest(user.username);
          },
          child: const Text('Kết bạn'),
        );
    }
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
} 