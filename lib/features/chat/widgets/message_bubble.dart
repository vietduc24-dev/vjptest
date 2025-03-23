import 'package:flutter/material.dart';
import '../../../../services/websocket/chatuser/chat_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat/chat_cubit.dart';
import '../cubit/chat/chat_state.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool shouldTranslate;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.shouldTranslate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is! ChatConnected) return const SizedBox.shrink();

        final translatedText = shouldTranslate ? state.translatedMessages[message.id] : null;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(
              left: isMe ? 64 : 8,
              right: isMe ? 8 : 64,
              bottom: 8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                if (translatedText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    translatedText,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
} 