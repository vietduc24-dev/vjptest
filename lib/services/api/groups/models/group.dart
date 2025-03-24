import 'dart:convert';

class Group {
  final String id;
  final String name;
  final List<String> members;
  final String creator;
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? joinedAt;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.creator,
    this.memberCount = 0,
    this.createdAt,
    this.joinedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    List<String> parseMembers(dynamic members) {
      if (members == null) return [];
      if (members is String) {
        return members.split(',').where((m) => m.isNotEmpty).toList();
      } else if (members is List) {
        return members.map((m) => m.toString()).where((m) => m.isNotEmpty).toList();
      }
      return [];
    }

    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      members: parseMembers(json['members']),
      creator: json['creator']?.toString() ?? '',
      memberCount: int.tryParse(json['member_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      joinedAt: json['joined_at'] != null ? DateTime.tryParse(json['joined_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'creator': creator,
      'member_count': memberCount,
      'created_at': createdAt?.toIso8601String(),
      'joined_at': joinedAt?.toIso8601String(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    List<String>? members,
    String? creator,
    int? memberCount,
    DateTime? createdAt,
    DateTime? joinedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      creator: creator ?? this.creator,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
} 