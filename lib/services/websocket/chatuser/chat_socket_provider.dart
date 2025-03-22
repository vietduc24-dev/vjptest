import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_socket_service.dart';
import '../../../services/api/authentication/auth_service.dart';

class ChatSocketProvider {
  final AuthService _authService;
  ChatSocketService? _socketService;

  ChatSocketProvider(this._authService);

  Future<ChatSocketService> getSocketService() async {
    if (_socketService != null) return _socketService!;

    final username = await _authService.getUsername();
    final token = await _authService.getToken();
      
    if (username == null || token == null) {
      throw Exception('Authentication information not found');
    }

    _socketService = ChatSocketService(
      wsUrl: 'ws://10.0.2.2:8090',
      username: username,
      token: token,
    );

    return _socketService!;
  }

  void dispose() {
    _socketService?.dispose();
    _socketService = null;
  }
} 