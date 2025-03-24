import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'group_message.dart';

class GroupChatSocketService {
  final WebSocketChannel _channel;
  final _messageController = StreamController<GroupMessage>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();
  final String groupId;
  final String userId;
  final String token;
  bool _isAuthenticated = false;
  
  // Thêm completer để đợi auth hoàn tất
  final Completer<void> _authCompleter = Completer<void>();

  Stream<GroupMessage> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;

  GroupChatSocketService({
    required String wsUrl,
    required this.groupId,
    required this.userId,
    required this.token,
  }) : _channel = WebSocketChannel.connect(Uri.parse(wsUrl)) {
    _setupConnection();
  }

  void _setupConnection() {
    // Đầu tiên gửi ws_auth để authenticate
    final authMsg = {
      'type': 'ws_auth',
      'token': token,
    };
    _channel.sink.add(jsonEncode(authMsg));

    _channel.stream.listen(
      (data) {
        _handleMessage(data);
      },
      onError: (error) {
        print('Group WebSocket error: $error');
        _isAuthenticated = false;
        if (!_authCompleter.isCompleted) {
          _authCompleter.completeError(error);
        }
      },
      onDone: () {
        print('Group WebSocket connection closed');
        _isAuthenticated = false;
        if (!_authCompleter.isCompleted) {
          _authCompleter.completeError('Connection closed');
        }
      },
    );
  }

  void _handleMessage(dynamic data) {
    try {
      print('WebSocket received raw data: $data');
      final Map<String, dynamic> messageData = jsonDecode(data as String);
      print('WebSocket decoded message data: $messageData');
      
      if (messageData['type'] == 'ws_auth_success') {
        _isAuthenticated = true;
        _authCompleter.complete();
        print('✅ Client authenticated: $userId');
      } else if (messageData['type'] == 'message' || messageData['type'] == 'group_message' || messageData['type'] == 'group_message_revoked') {
        if (messageData['group_id'] == groupId) {
          final message = GroupMessage.fromJson(messageData);
          print('WebSocket created GroupMessage: $message');
          _messageController.add(message);
        }
      } else if (messageData['type'] == 'typing_status') {
        _typingController.add(messageData);
      } else if (messageData['type'] == 'error') {
        print('❌ WebSocket error: ${messageData['message']}');
        if (!_isAuthenticated) {
          _authCompleter.completeError(messageData['message']);
        }
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  // Đợi auth hoàn tất trước khi gửi message
  void sendMessage(String content, {String? attachmentUrl, String? attachmentType}) {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final message = {
        'type': 'group_message',
        'group_id': groupId,
        'sender': userId,
        'message': content,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (attachmentUrl != null && attachmentType != null) {
        message['attachmentUrl'] = attachmentUrl;
        message['attachmentType'] = attachmentType;
      }

      print('Sending message: $message');
      _channel.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Đợi auth hoàn tất trước khi gửi typing status
  Future<void> sendTypingStatus(bool isTyping) async {
    try {
      await _authCompleter.future;
      
      if (!_isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final status = {
        'type': 'typing_status',
        'group_id': groupId,
        'sender': userId,
        'isTyping': isTyping,
      };
      _channel.sink.add(jsonEncode(status));
    } catch (e) {
      print('Error sending typing status: $e');
      rethrow;
    }
  }

  void revokeMessage(String messageId) {
    try {
      if (!_isAuthenticated) {
        throw Exception('Not authenticated');
      }

      final message = {
        'type': 'revoke_message',
        'group_id': groupId,
        'sender': userId,
        'message_id': messageId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      print('Sending revoke message: $message');
      _channel.sink.add(jsonEncode(message));
    } catch (e) {
      print('Error revoking message: $e');
      rethrow;
    }
  }

  void dispose() {
    _messageController.close();
    _typingController.close();
    _channel.sink.close();
  }
} 