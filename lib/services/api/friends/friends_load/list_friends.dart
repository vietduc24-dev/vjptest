import 'dart:convert';
import 'package:http/http.dart' as http;

class Friend {
  final String username;
  final String fullName;
  final String? avatar;
  final String? status;

  Friend({
    required this.username,
    required this.fullName,
    this.avatar,
    this.status,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatarUrl'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'avatarUrl': avatar,
      'status': status,
    };
  }
}
