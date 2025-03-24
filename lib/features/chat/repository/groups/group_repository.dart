import '../../../../services/api/groups/group_service.dart';
import '../../../../services/api/groups/models/group.dart';
import '../../../../services/websocket/chatgroup/group_chat_socket_service.dart';
import '../../../../services/websocket/chatgroup/group_message.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../services/api/cloudinary/cloudinary_service.dart';

class GroupRepository {
  final GroupService _groupService;
  final FlutterSecureStorage _storage;
  GroupChatSocketService? _socketService;

  GroupRepository(this._groupService) 
    : _storage = const FlutterSecureStorage();

  Future<String> _getUsernameFromToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['username'] as String;
  }

  Future<String> getCurrentUserId() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    
    final decodedToken = JwtDecoder.decode(token);
    final username = decodedToken['username'] as String;
    return username;
  }

  Future<List<Group>> getGroups() async {
    try {
      return await _groupService.getGroups();
    } catch (e) {
      throw Exception('Failed to load groups: ${e.toString()}');
    }
  }

  Future<Group> createGroup(String name, List<String> members) async {
    try {
      return await _groupService.createGroup(name, members);
    } catch (e) {
      throw Exception('Failed to create group: ${e.toString()}');
    }
  }

  Future<Group> getGroupInfo(String groupId) async {
    try {
      return await _groupService.getGroupInfo(groupId);
    } catch (e) {
      throw Exception('Failed to get group info: ${e.toString()}');
    }
  }

  Future<void> addMember(String groupId, String username) async {
    try {
      await _groupService.addMember(groupId, username);
    } catch (e) {
      throw Exception('Failed to add member: ${e.toString()}');
    }
  }

  Future<void> removeMember(String groupId, String username) async {
    try {
      await _groupService.removeMember(groupId, username);
    } catch (e) {
      throw Exception('Failed to remove member: ${e.toString()}');
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await _groupService.leaveGroup(groupId);
    } catch (e) {
      throw Exception('Failed to leave group: ${e.toString()}');
    }
  }

  Future<void> initializeGroupChat({
    required String groupId,
    required String wsUrl,
    required String currentUserId,
  }) async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('No authentication token found');
    }

    _socketService?.dispose();
    _socketService = GroupChatSocketService(
      wsUrl: wsUrl,
      groupId: groupId,
      userId: currentUserId,
      token: token,
    );
  }

  Stream<GroupMessage>? get messageStream => _socketService?.messageStream;
  Stream<Map<String, dynamic>>? get typingStream => _socketService?.typingStream;

  void sendMessage(String content, {File? imageFile}) {
    if (_socketService == null) {
      throw Exception('Chat service not initialized');
    }
    
    if (imageFile != null) {
      // Upload image to Cloudinary
      CloudinaryService.instance.uploadImage(imageFile).then((imageUrl) {
        if (imageUrl != null) {
          // Send message with image attachment
          _socketService!.sendMessage(
            content,
            attachmentUrl: imageUrl,
            attachmentType: 'image/${imageFile.path.split('.').last}',
          );
        }
      }).catchError((error) {
        throw Exception('Failed to upload image: $error');
      });
    } else {
      // Send text message only
      _socketService!.sendMessage(content);
    }
  }

  void sendTypingStatus(bool isTyping) {
    _socketService?.sendTypingStatus(isTyping);
  }

  void disposeChat() {
    _socketService?.dispose();
    _socketService = null;
  }

  Future<Map<String, dynamic>> getGroupMessages(String groupId, {int page = 1, int limit = 20}) async {
    try {
      return await _groupService.getGroupMessages(groupId, page: page, limit: limit);
    } catch (e) {
      throw Exception('Failed to load group messages: $e');
    }
  }
} 