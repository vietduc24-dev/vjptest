import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../services/api/groups/models/group.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<GroupsCubit>().loadGroupMessages(widget.group.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        context.read<GroupsCubit>().sendMessage('', imageFile: imageFile);
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
      context.read<GroupsCubit>().sendMessage(message, imageFile: imageFile);
      _textController.clear();
    }
  }

  void _handleTypingChanged(String text) {
    context.read<GroupsCubit>().updateTypingStatus(text.isNotEmpty);
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