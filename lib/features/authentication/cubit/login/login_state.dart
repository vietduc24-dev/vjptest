import 'package:equatable/equatable.dart';
import '../../../../models/user_model.dart';

enum LoginStatus { initial, loading, success, error }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final String? username;
  final User? user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.username,
    this.user,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    String? username,
    User? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      username: username ?? this.username,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, username, user];
}
