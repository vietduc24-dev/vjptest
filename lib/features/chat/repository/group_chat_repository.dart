import '../../../services/websocket/chatgroup/group_chat_socket_service.dart';
import '../../../services/websocket/chatgroup/group_message.dart';
import 'dart:io';

class GroupChatRepository {
  final GroupChatSocketService _socketService;
  
  Stream<GroupMessage> get messageStream => _socketService.messageStream;
  Stream<Map<String, dynamic>> get typingStream => _socketService.typingStream;

  GroupChatRepository(this._socketService);

  void sendMessage(String content, {File? imageFile}) {
    // TODO: Handle image upload if needed
    _socketService.sendMessage(content);
  }

  void sendTypingStatus(bool isTyping) {
    _socketService.sendTypingStatus(isTyping);
  }

  void dispose() {
    _socketService.dispose();
  }
} 