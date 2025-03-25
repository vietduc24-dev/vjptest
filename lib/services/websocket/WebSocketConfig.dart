import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketConfig {
  // Kiểm tra xem có phải đang chạy trên máy ảo Android không
  static bool get isAndroidEmulator {
    if (!Platform.isAndroid) return false;
    return Platform.environment.containsKey('ANDROID_EMULATOR') || 
           Platform.environment.containsKey('ANDROID_SDK_ROOT');
  }

  static String get wsUrl {
    if (kIsWeb) {
      return dotenv.env['WS_URL_WEB'] ?? 'ws://localhost:8090';
    }

    if (Platform.isAndroid) {
      // Phân biệt giữa máy ảo và thiết bị thật
      if (isAndroidEmulator) {
        debugPrint('📱 Running on Android Emulator');
        return dotenv.env['WS_URL_ANDROID'] ?? 'ws://10.0.2.2:8090';
      } else {
        debugPrint('📱 Running on Real Android Device');
        return dotenv.env['WS_URL_DEVICE'] ?? 'ws://192.168.0.76:8090';
      }
    }

    if (Platform.isIOS) {
      return dotenv.env['WS_URL_IOS'] ?? 'ws://localhost:8090';
    }

    return dotenv.env['WS_URL_DEVICE'] ?? 'ws://192.168.0.76:8090';
  }

  // Debug helper
  static void printWebSocketConfig() {
    debugPrint('🔌 WebSocket Configuration:');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('Is Android Emulator: $isAndroidEmulator');
    debugPrint('Is Web: $kIsWeb');
    debugPrint('WS URL: $wsUrl');
    debugPrint('ENV WS_URL_ANDROID: ${dotenv.env['WS_URL_ANDROID']}');
    debugPrint('ENV WS_URL_DEVICE: ${dotenv.env['WS_URL_DEVICE']}');
  }
}
