class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;
  final String? senderName;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
    this.attachmentType,
    this.senderName,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['sender'],
      receiverId: json['receiver'],
      content: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] as bool? ?? false,
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
      senderName: json['senderName'] as String?,
      senderAvatar: json['senderAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': senderId,
      'receiver': receiverId,
      'message': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      if (senderName != null) 'senderName': senderName,
      if (senderAvatar != null) 'senderAvatar': senderAvatar,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentUrl,
    String? attachmentType,
    String? senderName,
    String? senderAvatar,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  @override
  String toString() {
    return 'ChatMessage{id: $id, senderId: $senderId, receiverId: $receiverId, content: $content, timestamp: $timestamp, attachmentUrl: $attachmentUrl, attachmentType: $attachmentType}';
  }
} 