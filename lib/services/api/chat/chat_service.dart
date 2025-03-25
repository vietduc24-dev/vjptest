import '../../base/base_reponse.dart';
import '../../websocket/chatuser/chat_message.dart';
import 'api_provider_chat.dart';

import 'chat_endpoints.dart'; 
import 'package:flutter/foundation.dart';

class ChatService {
  static final ChatService instance = ChatService._internal();
  final ApiProviderChat _apiProvider = ApiProviderChat();

  ChatService._internal();

  Future<BaseResponse> getPersonalMessages(String username, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('Getting personal messages for user: $username');
      final response = await _apiProvider.get(
        ChatApiConstants.personalMessages + '/$username',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        }
      );
      debugPrint('Personal messages response: $response');

      if (response.success) {
        return BaseResponse(
          success: true,
          data: response.data,
          message: 'Success',
        );
      }

      return response;
    } catch (e) {
      debugPrint('Error getting personal messages: $e');
      rethrow;
    }
  }

  Future<BaseResponse> getGroupMessages(String groupId) async {
    try {
      debugPrint('Getting group messages for group: $groupId');
      final response = await _apiProvider.get(
        ChatApiConstants.groupMessages + '/$groupId',
      );
      debugPrint('Group messages response: $response');

      if (response.success) {
        final List<dynamic> messages = response.data as List<dynamic>;
        final chatMessages = messages.map((msg) => ChatMessage(
          id: msg['id'] as String,
          senderId: msg['sender'] as String,
          receiverId: msg['groupId'] as String,
          content: msg['message'] as String,
          timestamp: DateTime.parse(msg['timestamp'] as String),
          senderName: msg['senderName'] as String?,
          senderAvatar: msg['senderAvatar'] as String?,
        )).toList();

        return BaseResponse(success: true, data: chatMessages);
      }

      return response;
    } catch (e) {
      debugPrint('Error getting group messages: $e');
      rethrow;
    }
  }

  Future<BaseResponse> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    try {
      debugPrint('Sending message from $senderId to $receiverId');
      final data = {
        'sender': senderId,
        'receiver': receiverId,
        'message': content,
      };

      final response = await _apiProvider.post(
        ChatApiConstants.sendMessage,
        data: data
      );
      debugPrint('Send message response: $response');

      return response;
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }
}
