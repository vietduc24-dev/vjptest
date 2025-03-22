import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketConfig {
  static String get wsUrl {
    if (kIsWeb) {
      return dotenv.env['WS_URL_WEB'] ?? 'ws://localhost:8090';
    }

    if (Platform.isAndroid) {
      return dotenv.env['WS_URL_ANDROID'] ?? 'ws://10.0.2.2:8090';
    }

    if (Platform.isIOS) {
      return dotenv.env['WS_URL_IOS'] ?? 'ws://localhost:8090';
    }

    // Máy thật
    return dotenv.env['WS_URL_DEVICE'] ?? 'ws://192.168.1.10:8090';
  }
}
