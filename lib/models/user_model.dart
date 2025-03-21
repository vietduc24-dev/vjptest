class User {
  final String username;
  final String? companyName;
  final String? fullName;
  final String? phone;
  final String? nationality;
  final String? packageType;
  final String? avatarUrl;
  final String? token;

  User({
    required this.username,
    this.companyName,
    this.fullName,
    this.phone,
    this.nationality,
    this.packageType,
    this.avatarUrl,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      username: json['username'] as String,
      companyName: json['companyName'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      nationality: json['nationality'] as String?,
      packageType: json['packageType'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'companyName': companyName,
      'fullName': fullName,
      'phone': phone,
      'nationality': nationality,
      'packageType': packageType,
      'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? username,
    String? companyName,
    String? fullName,
    String? phone,
    String? nationality,
    String? packageType,
    String? avatarUrl,
    String? token,
  }) {
    return User(
      username: username ?? this.username,
      companyName: companyName ?? this.companyName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      packageType: packageType ?? this.packageType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
    );
  }
} 