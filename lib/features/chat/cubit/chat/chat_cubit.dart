import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/websocket/chatuser/chat_message.dart';
import '../../../../common/bloc_status.dart';
import '../../repository/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  Timer? _typingTimer;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;
  bool _isClosed = false;

  ChatCubit({
    required ChatRepository repository,
  }) : _chatRepository = repository,
       super(ChatInitial()) {
    initialize();
  }

  Future<void> initialize() async {
    if (_isClosed) return;
    
    try {
      emit(ChatLoading());
      
      final messages = await _chatRepository.getInitialMessages();
      
      if (_isClosed) return;
      emit(ChatConnected(
        messages: messages,
        isTyping: false,
      ));

      _messageSubscription = _chatRepository.messageStream.listen((message) {
        if (_isClosed || state.status == BlocStatus.failure) return;
        
        if (state is ChatConnected) {
          final currentState = state as ChatConnected;
          emit(ChatConnected(
            messages: [...currentState.messages, message],
            isTyping: currentState.isTyping,
            typingUserId: currentState.typingUserId,
          ));
        }
      });

      _statusSubscription = _chatRepository.statusStream.listen((data) {
        if (_isClosed || state.status == BlocStatus.failure) return;
        
        if (state is ChatConnected) {
          final currentState = state as ChatConnected;
          final status = data['status'] as String;
          final senderId = data['senderId'] as String;
          
          // Only show typing indicator if the sender is not the current user
          if (senderId != _chatRepository.currentUserId) {
            final isTyping = status == 'typing';
            
            emit(ChatConnected(
              messages: currentState.messages,
              isTyping: isTyping,
              typingUserId: isTyping ? senderId : null,
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

  @override
  Future<void> close() {
    _isClosed = true;
    _chatRepository.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    return super.close();
  }
} 