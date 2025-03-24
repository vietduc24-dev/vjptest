class GroupMessage {
  final String id;
  final String groupId;
  final String sender;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final String? attachmentUrl;
  final String? attachmentType;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.sender,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    print('GroupMessage.fromJson received data:');
    print('- id: ${json['id']}');
    print('- group_id: ${json['group_id']}');
    print('- sender: ${json['sender']}');
    print('- sender_name: ${json['sender_name']}');
    print('- message: ${json['message']}');
    print('- attachmentUrl: ${json['attachmentUrl']}');
    print('- attachmentType: ${json['attachmentType']}');
    print('- messageType: ${json['messageType']}');
    print('- timestamp: ${json['timestamp']}');

    return GroupMessage(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      groupId: json['group_id'] ?? '',
      sender: json['sender'] ?? '',
      senderName: json['sender_name'] ?? json['sender'] ?? '',
      senderAvatar: json['sender_avatar'],
      content: json['message'] ?? '',
      timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'])
        : DateTime.now(),
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender': sender,
      'sender_name': senderName,
      'sender_avatar': senderAvatar,
      'message': content,
      'timestamp': timestamp.toIso8601String(),
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
    };
  }
} 