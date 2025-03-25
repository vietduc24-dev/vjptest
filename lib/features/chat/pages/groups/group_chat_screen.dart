import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../services/api/groups/models/group.dart';
import '../../../../services/websocket/chatgroup/group_message.dart';
import '../../cubit/groups/groups_cubit.dart';
import '../../cubit/groups/groups_state.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/group_message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final Group group;
  final String currentUserId;

  const GroupChatScreen({
    super.key,
    required this.group,
    required this.currentUserId,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  late final GroupsCubit _groupsCubit;

  @override
  void initState() {
    super.initState();
    _groupsCubit = context.read<GroupsCubit>();
    _groupsCubit.loadGroupMessages(widget.group.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showRevokeDialog(BuildContext context, GroupMessage message) {
    print('Opening revoke dialog for message:');
    print('- Message ID: ${message.id}');
    print('- Message Content: ${message.content}');
    print('- Message Sender: ${message.sender}');
    print('- Current User: ${widget.currentUserId}');
    print('- Is Revoked: ${message.isRevoked}');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Thu hồi tin nhắn'),
        content: const Text('Bạn có chắc chắn muốn thu hồi tin nhắn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              print('Attempting to revoke message:');
              print('- Message ID: ${message.id}');
              print('- Current User: ${widget.currentUserId}');
              print('- GroupsCubit state before revoke:');
              print('- Messages count: ${_groupsCubit.state.messages.length}');
              print('- Status: ${_groupsCubit.state.status}');
              
              _groupsCubit.revokeMessage(message.id);
              
              print('Revoke message command sent');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Thu hồi'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        _groupsCubit.sendMessage('', imageFile: imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể chọn ảnh: $e')),
      );
    }
  }

  void _handleSendMessage(String message, {File? imageFile}) {
    if (message.isNotEmpty || imageFile != null) {
      print('Sending message as user: ${widget.currentUserId}');
      _groupsCubit.sendMessage(message, imageFile: imageFile);
      _textController.clear();
    }
  }

  void _handleTypingChanged(String text) {
    _groupsCubit.updateTypingStatus(text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name),
            Text(
              '${widget.group.memberCount} thành viên',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show group info
            },
          ),
        ],
      ),
      body: BlocBuilder<GroupsCubit, GroupsState>(
        bloc: _groupsCubit,
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    print('Message details:');
                    print('- currentUserId: ${widget.currentUserId}');
                    print('- message.sender: ${message.sender}');
                    print('- message.content: ${message.content}');
                    return GroupMessageBubble(
                      message: message,
                      isMe: message.sender == widget.currentUserId,
                      onRevoke: (message) => _showRevokeDialog(context, message),
                    );
                  },
                ),
              ),
              ChatInput(
                controller: _textController,
                onTypingChanged: _handleTypingChanged,
                onSendPressed: _handleSendMessage,
                onSubmitted: (message) => _handleSendMessage(message),
              ),
            ],
          );
        },
      ),
    );
  }
} 