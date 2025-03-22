import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onTypingChanged;
  final VoidCallback onSendPressed;
  final Function(String) onSubmitted;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onTypingChanged,
    required this.onSendPressed,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: Colors.grey[600],
              onPressed: () {
                // TODO: Implement file attachment
              },
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: onTypingChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onSendPressed,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 