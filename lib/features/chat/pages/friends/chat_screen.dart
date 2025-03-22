import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/websocket/chatuser/chat_message.dart';
import '../../repository/chat_repository.dart';
import '../../cubit/chat/chat_cubit.dart';
import '../../cubit/chat/chat_state.dart';
import '../../widgets/chat_app_bar.dart';
import '../../widgets/chat_input.dart';
import '../../widgets/chat_messages.dart';
import '../../widgets/chat_error_view.dart';

class ChatScreen extends StatefulWidget {
  final Friend friend;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.friend,
    required this.currentUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatCubit _chatCubit;
  bool _showScrollButton = false;
  List<ChatMessage> _previousMessages = [];

  bool _isTypingMessage(ChatMessage message) {
    return message.content == 'typing' || 
           message.content == 'stopped_typing' || 
           message.content == 'offline';
  }

  @override
  void initState() {
    super.initState();
    final repository = context.read<ChatRepository>();
    _chatCubit = ChatCubit(repository: repository);

    _scrollController.addListener(() {
      final showButton = _scrollController.position.pixels > 500;
      if (showButton != _showScrollButton) {
        setState(() => _showScrollButton = showButton);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatCubit.close();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    
    if (animated) {
      _scrollController.animateTo(
        0, // Scroll to top since ListView is reversed
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _chatCubit.sendMessage(message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: ChatAppBar(
          friend: widget.friend,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatConnected) {
                    // Cuộn xuống khi có tin nhắn mới (không phải typing status)
                    if (state.messages.isNotEmpty && _previousMessages.length < state.messages.length) {
                      final lastMessage = state.messages.last;
                      if (!_isTypingMessage(lastMessage)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom(animated: true);
                        });
                      }
                    }
                    _previousMessages = state.messages;
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return ChatErrorView(
                      error: state.error,
                      onRetry: () => _chatCubit.initialize(),
                    );
                  }

                  if (state is ChatConnected) {
                    return ChatMessages(
                      messages: state.messages,
                      currentUserId: widget.currentUserId,
                      friend: widget.friend,
                      isTyping: state.isTyping,
                      typingUserId: state.typingUserId,
                      scrollController: _scrollController,
                      showScrollButton: _showScrollButton,
                      onScrollToBottom: () => _scrollToBottom(),
                      isTypingMessage: _isTypingMessage,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            ChatInput(
              controller: _messageController,
              onTypingChanged: (value) {
                _chatCubit.sendTypingStatus(value.isNotEmpty);
              },
              onSendPressed: _handleSendMessage,
              onSubmitted: (_) => _handleSendMessage(),
            ),
          ],
        ),
      ),
    );
  }
} 