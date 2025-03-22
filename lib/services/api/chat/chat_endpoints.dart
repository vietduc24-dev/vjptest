import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ChatApiConstants {
  // Base URLs
   static String get baseUrl => dotenv.env['API_URL'] ?? 'http://localhost:3000/api';
  static const String wsBaseUrl = 'ws://10.0.2.2:8090';

  // Message Endpoints
  static String get personalMessages => '$baseUrl/messages/personal';
  static String get groupMessages => '$baseUrl/messages/group'; 
  static String get sendMessage => '$baseUrl/messages/send';

}
