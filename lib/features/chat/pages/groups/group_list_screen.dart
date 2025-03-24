import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api/groups/models/group.dart';
import '../../cubit/groups/groups_cubit.dart';
import '../../cubit/groups/groups_state.dart';
import '../../../../common/widgets/toast.dart';
import '../../../../common/colors.dart';
import 'create_group_screen.dart';
import '../../../../routes/app_router.dart';
import '../../../../services/websocket/WebSocketConfig.dart';
import '../../../../features/chat/pages/groups/group_chat_screen.dart';
import '../../repository/groups/group_repository.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupsCubit, GroupsState>(
      listener: (context, state) {
        if (state.status == GroupsStatus.error) {
          Toast.show(
            context,
            state.errorMessage ?? 'Đã có lỗi xảy ra',
            type: ToastType.error,
          );
        } else if (state.status == GroupsStatus.created) {
          Toast.show(
            context,
            'Tạo nhóm thành công',
            type: ToastType.success,
          );
        } else if (state.status == GroupsStatus.memberAdded) {
          Toast.show(
            context,
            'Đã thêm thành viên vào nhóm',
            type: ToastType.success,
          );
        } else if (state.status == GroupsStatus.memberRemoved) {
          Toast.show(
            context,
            'Đã xóa thành viên khỏi nhóm',
            type: ToastType.success,
          );
        } else if (state.status == GroupsStatus.left) {
          Toast.show(
            context,
            'Đã rời khỏi nhóm',
            type: ToastType.success,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nhóm chat'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateGroupDialog(context),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<GroupsCubit>().loadGroups(),
            child: _buildGroupList(context, state),
          ),
        );
      },
    );
  }

  Widget _buildGroupList(BuildContext context, GroupsState state) {
    if (state.status == GroupsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có nhóm nào',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showCreateGroupDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIColors.redLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tạo nhóm mới'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<String>(
      future: context.read<GroupRepository>().getCurrentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Không thể lấy thông tin người dùng'));
        }

        final currentUserId = snapshot.data!;
        print('Current user ID from token: $currentUserId');
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.groups.length,
          itemBuilder: (context, index) {
            final group = state.groups[index];
            return _GroupTile(
              group: group,
              currentUserId: currentUserId,
            );
          },
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    AppRouter.goToCreateGroup(context);
  }
}

class _GroupTile extends StatelessWidget {
  final Group group;
  final String currentUserId;

  const _GroupTile({
    required this.group,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: UIColors.redLight,
          child: Text(
            group.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(group.name),
        subtitle: Text('${group.memberCount} thành viên'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('Thông tin nhóm'),
                ],
              ),
            ),
            if (group.creator != currentUserId)
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app),
                    SizedBox(width: 8),
                    Text('Rời nhóm'),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'info') {
              _showGroupInfo(context, group);
            } else if (value == 'leave') {
              _showLeaveConfirmation(context, group);
            }
          },
        ),
        onTap: () {
          print('Current user ID in GroupListScreen: $currentUserId');
          AppRouter.goToGroupChat(
            context,
            group,
            currentUserId,
          );
        },
      ),
    );
  }

  void _showGroupInfo(BuildContext context, Group group) {
    showModalBottomSheet(
      context: context,
      builder: (context) => GroupInfoSheet(group: group),
    );
  }

  void _showLeaveConfirmation(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời nhóm'),
        content: Text('Bạn có chắc muốn rời khỏi nhóm "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<GroupsCubit>().leaveGroup();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Rời nhóm'),
          ),
        ],
      ),
    );
  }
}

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final _memberController = TextEditingController();
  final List<String> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo nhóm mới'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên nhóm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _memberController,
            decoration: InputDecoration(
              labelText: 'Thêm thành viên',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addMember,
              ),
            ),
          ),
          if (_selectedMembers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _selectedMembers
                  .map((member) => Chip(
                        label: Text(member),
                        onDeleted: () => _removeMember(member),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _createGroup,
          style: ElevatedButton.styleFrom(
            backgroundColor: UIColors.redLight,
            foregroundColor: Colors.white,
          ),
          child: const Text('Tạo nhóm'),
        ),
      ],
    );
  }

  void _addMember() {
    final member = _memberController.text.trim();
    if (member.isNotEmpty && !_selectedMembers.contains(member)) {
      setState(() {
        _selectedMembers.add(member);
        _memberController.clear();
      });
    }
  }

  void _removeMember(String member) {
    setState(() {
      _selectedMembers.remove(member);
    });
  }

  void _createGroup() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && _selectedMembers.isNotEmpty) {
      context.read<GroupsCubit>().createGroup(name, _selectedMembers);
      Navigator.pop(context);
    }
  }
}

class GroupInfoSheet extends StatelessWidget {
  final Group group;

  const GroupInfoSheet({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: context.read<GroupRepository>().getCurrentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Không thể lấy thông tin người dùng'));
        }

        final currentUserId = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: UIColors.redLight,
                    radius: 30,
                    child: Text(
                      group.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${group.memberCount} thành viên',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Thành viên',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: group.members.length,
                  itemBuilder: (context, index) {
                    final member = group.members[index];
                    final isCreator = member == group.creator;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member[0].toUpperCase()),
                      ),
                      title: Text(member),
                      subtitle: isCreator
                          ? const Text(
                              'Người tạo nhóm',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            )
                          : null,
                      trailing: isCreator || member == currentUserId
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.red,
                              onPressed: () => _showRemoveMemberDialog(
                                context,
                                member,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRemoveMemberDialog(BuildContext context, String member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Bạn có chắc muốn xóa $member khỏi nhóm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<GroupsCubit>().removeMember(member);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
} 