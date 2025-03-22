import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_message.dart';

class ChatSocketService {
  final WebSocketChannel _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _statusController = StreamController<String>.broadcast();
  final String username;
  final String token;
  bool _isAuthenticated = false;

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<String> get statusStream => _statusController.stream;

  ChatSocketService({
    required String wsUrl,
    required this.username,
    required this.token,
  }) : _channel = WebSocketChannel.connect(Uri.parse(wsUrl)) {
    print('Connecting to WebSocket at $wsUrl');
    _setupConnection();
  }

  void _setupConnection() {
    // Send authentication message with JWT token
    final authMsg = {
      'type': 'ws_auth',
      'token': token,
    };
    print('Sending WebSocket authentication');
    _channel.sink.add(jsonEncode(authMsg));

    // Listen for messages
    _channel.stream.listen(
      (dynamic data) {
        print('Received WebSocket message: $data');
        final Map<String, dynamic> message = jsonDecode(data);
        
        if (message['type'] == 'ws_auth_success') {
          print('WebSocket authenticated successfully');
          _isAuthenticated = true;
        } else if (message['type'] == 'message') {
          final chatMessage = ChatMessage(
            id: message['id'].toString(),
            senderId: message['sender'],
            receiverId: message['receiver'],
            content: message['message'] ?? '',
            timestamp: DateTime.parse(message['timestamp']),
            attachmentUrl: message['attachmentUrl'],
            attachmentType: message['attachmentType'],
          );
          _messageController.add(chatMessage);
        } else if (message['type'] == 'error') {
          print('WebSocket error: ${message['message']}');
          if (!_isAuthenticated) {
            // Try to authenticate again if token error
            _channel.sink.add(jsonEncode(authMsg));
          }
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isAuthenticated = false;
      },
      onDone: () {
        print('WebSocket connection closed');
        _isAuthenticated = false;
      },
    );
  }

  void sendMessage(ChatMessage message) {
    if (!_isAuthenticated) {
      print('Cannot send message: Not authenticated');
      return;
    }

    if (message.content == 'typing' || 
        message.content == 'stopped_typing' || 
        message.content == 'offline') {
      // Handle status messages
      _statusController.add(jsonEncode({
        'status': message.content,
        'senderId': message.senderId
      }));
      return;
    }

    // Determine message type
    final messageType = message.attachmentUrl != null ? 'image' : 'text';
    print('Preparing to send ${messageType} message');

    final data = {
      'type': messageType,
      'sender': message.senderId,
      'receiver': message.receiverId,
      'message': message.content,
      'attachmentUrl': message.attachmentUrl,
      'attachmentType': message.attachmentType,
    };
    
    print('Sending WebSocket message: $data');
    try {
      _channel.sink.add(jsonEncode(data));
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void dispose() {
    print('Disposing WebSocket connection');
    _messageController.close();
    _statusController.close();
    _channel.sink.close();
  }
} 