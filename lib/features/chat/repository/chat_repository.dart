import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../../../services/websocket/chatuser/chat_message.dart';
import '../../../services/websocket/chatuser/chat_socket_service.dart';
import '../../../services/api/chat/chat_service.dart';
import '../../../services/api/cloudinary/cloudinary_service.dart';

class ChatRepository {
  final ChatSocketService _socketService;
  final String currentUserId;
  final String receiverId;

  ChatRepository({
    required ChatSocketService socketService,
    required this.currentUserId,
    required this.receiverId,
  }) : _socketService = socketService;

  // Stream getters
  Stream<ChatMessage> get messageStream => _socketService.messageStream;
  Stream<Map<String, dynamic>> get statusStream => 
    _socketService.statusStream.map((jsonStr) => jsonDecode(jsonStr) as Map<String, dynamic>);

  // Load initial messages
   Future<Map<String, dynamic>> getInitialMessages({int page = 1, int limit = 20}) async {
    try {
      final response = await ChatService.instance.getPersonalMessages(
        receiverId,
        page: page,
        limit: limit,
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to load messages');
      }

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> rawMessages = data['messages'] as List<dynamic>;
      final messages = rawMessages.map((msg) => ChatMessage.fromJson(msg)).toList();
      
      // Sort messages by timestamp in descending order (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return {
        'messages': messages,
        'hasMore': data['hasMore'] as bool,
        'total': data['total'] as int,
        'page': data['page'] as int,
        'limit': data['limit'] as int,
      };
    } catch (e) {
      print('Error loading messages: $e');
      throw Exception('Failed to load messages: $e');
    }
  
  }

  // Send a new message
  Future<void> sendMessage(String content, {File? imageFile}) async {
    try {
      String? attachmentUrl;
      String? attachmentType;

      if (imageFile != null) {
        // Upload image to Cloudinary
        attachmentUrl = await CloudinaryService.instance.uploadImage(imageFile);
        if (attachmentUrl != null) {
          attachmentType = 'image/${imageFile.path.split('.').last}';
        }
      }

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
        attachmentUrl: attachmentUrl,
        attachmentType: attachmentType,
      );
      
      _socketService.sendMessage(message);
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Send typing status
  void sendTypingStatus(bool isTyping) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      receiverId: receiverId,
      content: isTyping ? 'typing' : 'stopped_typing',
      timestamp: DateTime.now(),
    );
    _socketService.sendMessage(message);
  }

  // Send offline status
  void sendOfflineStatus() {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      receiverId: receiverId,
      content: 'offline',
      timestamp: DateTime.now(),
    );
    _socketService.sendMessage(message);
  }

  void dispose() {
    sendOfflineStatus();
  }
}
