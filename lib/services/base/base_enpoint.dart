import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../base/method_request.dart';

class EndpointType {
  EndpointType({
    this.path,
    this.httpMethod,
    this.parameters,
    this.header = const {},
  });

  String? path;
  HttpMethod? httpMethod;
  Map<String, dynamic>? parameters;
  Map<String, String> header;
}

class FileEndpointType {
  FileEndpointType({this.path, required this.file});

  String? path;
  File file;
}

class DefaultHeader {
  DefaultHeader._();

  static final DefaultHeader instance = DefaultHeader._();

  Map<String, String> addDefaultHeader() {
    return {
      "Content-Type": "application/json",
    };
  }
}

class BaseEndpoint {
  static String get baseUrl {
    if (kIsWeb) {
      return dotenv.env['API_URL_WEB'] ?? 'https://your-web-api.com/api';
    }

    if (Platform.isAndroid) {
      return dotenv.env['API_URL_ANDROID'] ?? 'http://10.0.2.2:3000/api';
    }

    if (Platform.isIOS) {
      return dotenv.env['API_URL_IOS'] ?? 'http://localhost:3000/api';
    }

    // Máy thật (device) — nên dùng IP LAN thật của backend
    return dotenv.env['API_URL'] ?? 'http://192.168.1.10:3000/api';
  }

  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static String getFullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
