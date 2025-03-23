import '../../../../services/websocket/chatuser/chat_message.dart';
import '../../../../common/bloc_status.dart';
import '../../../../services/translation/translation_preferences.dart';

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
  final TranslationLanguage translationLanguage;
  final Map<String, String> translatedMessages; // key: messageId, value: translated text

  ChatConnected({
    required this.messages,
    required this.isTyping,
    this.typingUserId,
    this.hasMore = true,
    this.currentPage = 1,
    this.translationLanguage = TranslationLanguage.none,
    this.translatedMessages = const {},
  }) : super(BlocStatus.success);

  ChatConnected copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? typingUserId,
    bool? hasMore,
    int? currentPage,
    TranslationLanguage? translationLanguage,
    Map<String, String>? translatedMessages,
  }) {
    return ChatConnected(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      typingUserId: typingUserId ?? this.typingUserId,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      translatedMessages: translatedMessages ?? this.translatedMessages,
    );
  }
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error) : super(BlocStatus.failure);
} 