import 'package:equatable/equatable.dart';
import '../../../../models/user_model.dart';
import '../../../../common/bloc_status.dart';


class LoginState extends Equatable {
  final BlocStatus status;
  final String? errorMessage;
  final String? username;
  final User? user;

  const LoginState({
    this.status = BlocStatus.initial,
    this.errorMessage,
    this.username,
    this.user,
  });

  LoginState copyWith({
    BlocStatus? status,
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
