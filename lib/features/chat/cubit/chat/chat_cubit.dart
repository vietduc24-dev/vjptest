import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/websocket/chatuser/chat_message.dart';
import '../../../../common/bloc_status.dart';
import '../../repository/chat_repository.dart';
import '../../../../services/translation/translation_preferences.dart';
import '../../../../services/translation/message_translation_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  Timer? _typingTimer;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;
  bool _isClosed = false;
  int _currentPage = 1;
  bool _hasMore = true;
  TranslationLanguage _currentLanguage = TranslationLanguage.none;
  final Map<String, String> _translatedMessages = {};
  StreamSubscription<String>? _revokedMessageSubscription;

  ChatCubit({
    required ChatRepository repository,
  }) : _chatRepository = repository,
       super(ChatInitial()) {
    initialize();
    _loadTranslationPreference();
  }

  Future<void> _loadTranslationPreference() async {
    _currentLanguage = await TranslationPreferences.getLanguage();
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(translationLanguage: _currentLanguage));
    }
  }

  Future<void> setTranslationLanguage(TranslationLanguage language) async {
    await TranslationPreferences.setLanguage(language);
    _currentLanguage = language;
    _translatedMessages.clear(); // Clear cached translations when language changes
    
    if (state is ChatConnected) {
      final currentState = state as ChatConnected;
      emit(currentState.copyWith(
        translationLanguage: language,
        translatedMessages: Map.from(_translatedMessages),
      ));
      
      // Start translating messages with new language
      await _translateMessages(currentState.messages);
    }
  }

  Future<void> _translateMessages(List<ChatMessage> messages) async {
    if (_currentLanguage == TranslationLanguage.none) return;
    
    for (var message in messages) {
      if (message.senderId != _chatRepository.currentUserId && 
          !_translatedMessages.containsKey(message.id)) {
        try {
          final translatedText = await MessageTranslationService.translateMessageIfNeeded(
            message.content,
          );
          
          if (translatedText != null) {
            _translatedMessages[message.id] = translatedText;
            if (state is ChatConnected) {
              final currentState = state as ChatConnected;
              emit(currentState.copyWith(
                translatedMessages: Map.from(_translatedMessages),
              ));
            }
          }
        } catch (e) {
          print('Error translating message: $e');
        }
      }
    }
  }

  Future<void> initialize() async {
    if (_isClosed) return;
    
    try {
      emit(ChatLoading());
      
      final result = await _chatRepository.getInitialMessages();
      final Map<String, dynamic> data = result as Map<String, dynamic>;
      
      _messages = (data['messages'] as List).cast<ChatMessage>();
      _hasMore = data['hasMore'] as bool;
      _currentPage = data['page'] as int;
      
      if (_isClosed) return;
      emit(ChatConnected(
        messages: _messages,
        isTyping: false,
        hasMore: _hasMore,
        currentPage: _currentPage,
        translationLanguage: _currentLanguage,
        translatedMessages: _translatedMessages,
      ));

      // Start translating initial messages
      await _translateMessages(_messages);

      _messageSubscription = _chatRepository.messageStream.listen((message) {
        if (_isClosed || state.status == BlocStatus.failure) return;
        
        if (state is ChatConnected) {
          final currentState = state as ChatConnected;
          _messages = [message, ...currentState.messages];
          emit(currentState.copyWith(
            messages: _messages,
          ));
          // Translate new message if needed
          _translateMessages([message]);
        }
      });

      // Thêm lắng nghe sự kiện thu hồi tin nhắn
      _revokedMessageSubscription = _chatRepository.messageRevokedStream.listen((messageId) {
        if (_isClosed || state.status == BlocStatus.failure) return;
        
        if (state is ChatConnected) {
          final currentState = state as ChatConnected;
          
          // Tìm và cập nhật tin nhắn đã bị thu hồi
          final updatedMessages = currentState.messages.map((message) {
            if (message.id == messageId) {
              // Tạo phiên bản mới của tin nhắn với trạng thái isRevoked = true
              return message.copyWith(
                isRevoked: true,
                content: "Tin nhắn đã được thu hồi",
                attachmentUrl: null,
                attachmentType: null,
              );
            }
            return message;
          }).toList();
          
          _messages = updatedMessages;
          emit(currentState.copyWith(messages: _messages));
        }
      });

      _statusSubscription = _chatRepository.statusStream.listen((data) {
        if (_isClosed || state.status == BlocStatus.failure) return;
        
        if (state is ChatConnected && data['type'] != 'message_revoked') {
          final currentState = state as ChatConnected;
          final status = data['status'] as String;
          final senderId = data['senderId'] as String;
          
          if (senderId != _chatRepository.currentUserId) {
            final isTyping = status == 'typing';
            
            emit(ChatConnected(
              messages: currentState.messages,
              isTyping: isTyping,
              typingUserId: isTyping ? senderId : null,
              hasMore: _hasMore,
              currentPage: _currentPage,
            ));
          }
        }
      });

    } catch (e) {
      if (!_isClosed) {
        emit(ChatError(e.toString()));
      }
    }
  }

  Future<void> sendMessage(String content, {File? imageFile}) async {
    if (_isClosed || state.status == BlocStatus.failure) return;
    
    try {
      await _chatRepository.sendMessage(content, imageFile: imageFile);
    } catch (e) {
      print('Error sending message: $e');
      if (!_isClosed) {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  Future<void> revokeMessage(String messageId) async {
    if (_isClosed || state.status == BlocStatus.failure) return;
    
    try {
        await _chatRepository.revokePersonalMessage(messageId);
    
      // Server sẽ gửi lại một message mới với trạng thái isRevoked=true
      // thông qua WebSocket, nên chúng ta không cần update state trực tiếp
    } catch (e) {
      print('Error revoking message: $e');
      if (!_isClosed) {
        emit(ChatError('Failed to revoke message: $e'));
      }
    }
  }

  void sendTypingStatus(bool isTyping) {
    if (_isClosed || state.status == BlocStatus.failure) return;
    
    _typingTimer?.cancel();

    if (isTyping) {
      _chatRepository.sendTypingStatus(true);
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (!_isClosed) {
          _chatRepository.sendTypingStatus(false);
        }
      });
    } else {
      _chatRepository.sendTypingStatus(false);
    }
  }

  Future<List<ChatMessage>> loadMoreMessages() async {
    if (_isClosed || !_hasMore || state.status != BlocStatus.success) {
      return [];
    }

    try {
      final nextPage = _currentPage + 1;
      final result = await _chatRepository.getInitialMessages(limit: 20, page: nextPage);
      final Map<String, dynamic> data = result as Map<String, dynamic>;
      
      final List<ChatMessage> moreMessages = (data['messages'] as List).cast<ChatMessage>();
      _hasMore = data['hasMore'] as bool;
      _currentPage = data['page'] as int;

      if (moreMessages.isNotEmpty) {
        _messages = [..._messages, ...moreMessages];
        
        if (state is ChatConnected) {
          emit(ChatConnected(
            messages: _messages,
            isTyping: (state as ChatConnected).isTyping,
            typingUserId: (state as ChatConnected).typingUserId,
            hasMore: _hasMore,
            currentPage: _currentPage,
          ));
        }
      }

      return moreMessages;
    } catch (e) {
      print('Error loading more messages: $e');
      return [];
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    _chatRepository.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    _revokedMessageSubscription?.cancel();
    return super.close();
  }
} 