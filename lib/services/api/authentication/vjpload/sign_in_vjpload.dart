class SignInVjpload {
  final String username;
  final String password;

  SignInVjpload({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
