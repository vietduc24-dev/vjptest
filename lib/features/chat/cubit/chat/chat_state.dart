import '../../../../services/websocket/chatuser/chat_message.dart';
import '../../../../common/bloc_status.dart';

abstract class ChatState {
  final BlocStatus status;
  
  ChatState(this.status);
}

class ChatInitial extends ChatState {
  ChatInitial() : super(BlocStatus.initial);
}

class ChatLoading extends ChatState {
  ChatLoading() : super(BlocStatus.loading);
}

class ChatConnected extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? typingUserId;
 final bool hasMore;  
  final int currentPage; 
  ChatConnected({
    required this.messages,
    required this.isTyping,
    this.typingUserId,
    this.hasMore = true,
    this.currentPage = 1,
  }) : super(BlocStatus.success);
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error) : super(BlocStatus.failure);
} 