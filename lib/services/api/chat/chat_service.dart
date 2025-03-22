import '../../base/base_reponse.dart';
import '../../websocket/chatuser/chat_message.dart';
import 'api_provider_chat.dart';

import 'chat_endpoints.dart'; // ✅ import lại đúng chỗ

class ChatService {
  static final ChatService instance = ChatService._internal();
  final ApiProviderChat _apiProvider = ApiProviderChat();

  ChatService._internal();

  Future<BaseResponse> getPersonalMessages(String username) async {
    return _apiProvider.get('${ChatApiConstants.personalMessages}/$username');
  }

  Future<BaseResponse> getGroupMessages(String groupId) async {
    final response = await _apiProvider.get(
      '${ChatApiConstants.groupMessages}/$groupId',
    );

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
  }

  Future<BaseResponse> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    final data = {
      'sender': senderId,
      'receiver': receiverId,
      'message': content,
    };

    return _apiProvider.post(ChatApiConstants.sendMessage, data: data);
  }
}
