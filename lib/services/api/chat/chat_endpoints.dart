import 'dart:io';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['API_URL_WEB'] ?? 'https://api.example.com/api';
    }

    if (Platform.isAndroid) {
      // Android emulator dùng 10.0.2.2 để trỏ về localhost
      return dotenv.env['API_URL_ANDROID'] ?? 'http://10.0.2.2:3000/api';
    }

    if (Platform.isIOS) {
      // iOS Simulator có thể dùng localhost
      return dotenv.env['API_URL_IOS'] ?? 'http://localhost:3000/api';
    }

    // Mặc định cho máy thật (Android physical device hoặc iOS real device)
    return dotenv.env['API_URL'] ?? 'http://192.168.1.10:3000/api'; // <-- đổi thành IP máy oppa nếu cần
  }

  static const String wsBaseUrl = 'ws://10.0.2.2:8090';

  // Message Endpoints
  static String get personalMessages => '$baseUrl/messages/personal';
  static String get groupMessages => '$baseUrl/messages/group';
  static String get sendMessage => '$baseUrl/messages/send';
}
