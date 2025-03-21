class SignUpVjpload {
  final String username;
  final String password;
  final String fullName;
  final String? phone;
  final String? nationality;
  final String? companyName;
  final String? packageType;

  SignUpVjpload({
    required this.username,
    required this.password,
    required this.fullName,
    this.phone,
    this.nationality,
    this.companyName,
    this.packageType,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'fullName': fullName,
    'phone': phone,
    'nationality': nationality,
    'companyName': companyName,
    'packageType': packageType,
  };
}