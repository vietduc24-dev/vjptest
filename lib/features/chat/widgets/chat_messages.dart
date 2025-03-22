import 'package:flutter/material.dart';
import '../../../services/api/friends/friends_load/list_friends.dart';
import '../../../services/websocket/chatuser/chat_message.dart';
import 'chat_message_item.dart';

class ChatMessages extends StatelessWidget {
  final List<ChatMessage> messages;
  final String currentUserId;
  final Friend friend;
  final bool isTyping;
  final String? typingUserId;
  final ScrollController scrollController;
  final bool showScrollButton;
  final VoidCallback onScrollToBottom;
  final bool Function(ChatMessage) isTypingMessage;

  const ChatMessages({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.friend,
    required this.isTyping,
    required this.typingUserId,
    required this.scrollController,
    required this.showScrollButton,
    required this.onScrollToBottom,
    required this.isTypingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: EdgeInsets.only(
            left: 8,
            right: 8,
            top: 16,
            bottom: isTyping ? 60 : 16,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[messages.length - 1 - index];
            final isMe = message.senderId == currentUserId;
            return ChatMessageItem(
              message: message,
              isMe: isMe,
            );
          },
        ),
        if (showScrollButton)
          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.blue[600]?.withOpacity(0.9),
              onPressed: onScrollToBottom,
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ),
          ),
        if (isTyping && messages.isNotEmpty && 
            !isTypingMessage(messages.last) &&
            typingUserId != currentUserId)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: friend.avatar != null
                        ? NetworkImage(friend.avatar!)
                        : null,
                    backgroundColor: Colors.blue[300],
                    child: friend.avatar == null
                        ? Text(
                            friend.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Typing...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
} 