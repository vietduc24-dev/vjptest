import 'package:flutter/material.dart';
import '../../../../services/api/friends/friends_load/list_friends.dart';
import '../../../../services/websocket/chatuser/chat_message.dart';
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
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final VoidCallback onLoadMore;

  const ChatMessages({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.friend,
    required this.isTyping,
    this.typingUserId,
    required this.scrollController,
    required this.showScrollButton,
    required this.onScrollToBottom,
    required this.isTypingMessage,
    required this.isLoadingMore,
    required this.hasMoreMessages,
    required this.onLoadMore,
  });

  bool _shouldTranslateMessage(int index, ChatMessage message) {
    // Only translate messages from friend (not from current user)
    if (message.senderId == currentUserId) return false;
    
    // Only translate the 3 most recent non-typing messages
    int nonTypingMessageCount = 0;
    for (int i = messages.length - 1; i >= 0 && nonTypingMessageCount < 3; i--) {
      if (!isTypingMessage(messages[i])) {
        nonTypingMessageCount++;
        if (i == index) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              if (scrollController.position.pixels >= 
                  scrollController.position.maxScrollExtent - 200) {
                onLoadMore();
              }
            }
            return true;
          },
          child: ListView.builder(
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: messages.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (isLoadingMore && index == 0) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final actualIndex = isLoadingMore ? index - 1 : index;
              final message = messages[actualIndex];

              if (isTypingMessage(message)) {
                return const SizedBox.shrink();
              }

              return ChatMessageItem(
                message: message,
                isMe: message.senderId == currentUserId,
                shouldTranslate: _shouldTranslateMessage(actualIndex, message),
              );
            },
          ),
        ),
        if (showScrollButton)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              mini: true,
              onPressed: onScrollToBottom,
              child: const Icon(Icons.arrow_downward),
            ),
          ),
        if (isTyping && typingUserId != currentUserId)
          Positioned(
            left: 16,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${friend.fullName} đang nhập...',
                style: const TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }
} 