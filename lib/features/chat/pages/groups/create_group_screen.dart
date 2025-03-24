import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/groups/groups_cubit.dart';
import '../../repository/friends/friends_repository.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../common/widgets/loading_overlay.dart';
import '../../../../common/colors.dart';
import '../../../../routes/app_router.dart';
import '../../cubit/friends/firends_cubit.dart';
import '../../cubit/friends/firends_state.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<Friend> _selectedFriends = [];
  final _debounce = Debouncer(milliseconds: 500);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadFriends());
  }

  Future<void> _loadFriends() async {
    if (!mounted) return;
    context.read<FriendsCubit>().loadFriends();
  }

  void _onSearchChanged(String query) {
    _debounce.run(() {
      if (!mounted) return;
      if (query.trim().isNotEmpty) {
        context.read<FriendsCubit>().searchUsers(query);
      } else {
        context.read<FriendsCubit>().loadFriends();
      }
    });
  }

  void _toggleFriendSelection(Friend friend) {
    setState(() {
      if (_selectedFriends.contains(friend)) {
        _selectedFriends.remove(friend);
      } else {
        _selectedFriends.add(friend);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên nhóm'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một thành viên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<GroupsCubit>().createGroup(
        _groupNameController.text.trim(),
        _selectedFriends.map((friend) => friend.username).toList(),
      );
      if (mounted) {
        AppRouter.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tạo nhóm: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhóm mới'),
            if (_selectedFriends.isNotEmpty)
              Text(
                'Đã chọn: ${_selectedFriends.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _groupNameController,
                    decoration: const InputDecoration(
                      hintText: 'Tên nhóm',
                      prefixIcon: Icon(Icons.camera_alt),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Tìm tên hoặc số điện thoại',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'GẦN ĐÂY',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FriendsCubit, FriendsState>(
                builder: (context, state) {
                  if (state is FriendsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FriendsError) {
                    return Center(child: Text(state.message));
                  }

                  List<Friend> friends = [];
                  if (state is FriendsLoaded) {
                    friends = state.friends.items;
                  } else if (state is SearchResultsLoaded) {
                    friends = state.searchResults;
                  }

                  if (friends.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy kết quả'),
                    );
                  }

                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final isSelected = _selectedFriends.contains(friend);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: friend.avatar != null
                              ? NetworkImage(friend.avatar!)
                              : null,
                          backgroundColor: friend.avatar == null ? UIColors.redLight : null,
                          child: friend.avatar == null
                              ? Text(
                                  friend.username[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                )
                              : null,
                        ),
                        title: Text(friend.username),
                        subtitle: Text('1 phút'),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleFriendSelection(friend),
                          shape: const CircleBorder(),
                          activeColor: Colors.blue,
                        ),
                        onTap: () => _toggleFriendSelection(friend),
                      );
                    },
                  );
                },
              ),
            ),
            if (_selectedFriends.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedFriends.length,
                          itemBuilder: (context, index) {
                            final friend = _selectedFriends[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                backgroundImage: friend.avatar != null
                                    ? NetworkImage(friend.avatar!)
                                    : null,
                                backgroundColor: friend.avatar == null ? UIColors.redLight : null,
                                child: friend.avatar == null
                                    ? Text(
                                        friend.username[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _createGroup,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
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