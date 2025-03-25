import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['API_URL_WEB'] ?? 'http://localhost:3000/api';
    }

    if (Platform.isAndroid) {
      // Kiểm tra xem có phải là thiết bị thật không
      return dotenv.env['API_URL'] ?? 'http://192.168.0.76:3000/api';
    }

    if (Platform.isIOS) {
      // iOS Simulator có thể dùng localhost
      return dotenv.env['API_URL_IOS'] ?? 'http://localhost:3000/api';
    }

    // Mặc định cho các trường hợp khác
    return dotenv.env['API_URL'] ?? 'http://192.168.0.76:3000/api';
  }

  static String get wsBaseUrl {
    if (kIsWeb) {
      return dotenv.env['WS_URL_WEB'] ?? 'ws://localhost:8090';
    }

    if (Platform.isAndroid) {
      // Kiểm tra xem có phải là thiết bị thật không
      return dotenv.env['WS_URL_DEVICE'] ?? 'ws://192.168.0.76:8090';
    }

    if (Platform.isIOS) {
      return dotenv.env['WS_URL_IOS'] ?? 'ws://localhost:8090';
    }

    return dotenv.env['WS_URL_DEVICE'] ?? 'ws://192.168.0.76:8090';
  }

  // Message Endpoints
  static String get personalMessages => '/messages/personal';
  static String get groupMessages => '/messages/group';
  static String get sendMessage => '/messages/send';
}
