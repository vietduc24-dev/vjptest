import 'chat_socket_service.dart';
import '../../../services/api/authentication/auth_service.dart';
import '../WebSocketConfig.dart';
import 'package:flutter/foundation.dart';

class ChatSocketProvider {
  final AuthService _authService;
  ChatSocketService? _socketService;

  ChatSocketProvider(this._authService);

  Future<ChatSocketService> getSocketService() async {
    if (_socketService != null) return _socketService!;

    final username = await _authService.getUsername();
    final token = await _authService.getToken();
      
    if (username == null || token == null) {
      debugPrint('❌ WebSocket initialization failed: Authentication information not found');
      throw Exception('Authentication information not found');
    }

    debugPrint('🔌 Initializing WebSocket connection...');
    debugPrint('👤 Username: $username');
    debugPrint('🔑 Token: ${token.substring(0, 10)}...');
    
    // Print WebSocket configuration
    WebSocketConfig.printWebSocketConfig();

    _socketService = ChatSocketService(
      wsUrl: WebSocketConfig.wsUrl,
      username: username,
      token: token,
    );

    debugPrint('✅ WebSocket service initialized successfully');
    return _socketService!;
  }

  void dispose() {
    debugPrint('🔌 Disposing WebSocket connection...');
    _socketService?.dispose();
    _socketService = null;
    debugPrint('✅ WebSocket connection disposed');
  }
} 