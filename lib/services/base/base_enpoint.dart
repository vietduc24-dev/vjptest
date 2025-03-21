import 'dart:io';
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
    Map<String, String> header = <String, String>{};
    header["Content-Type"] = "application/json";
    return header;
  }
}

class BaseEndpoint {
  static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Add other endpoints here
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
