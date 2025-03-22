import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/authentication_repository.dart';
import 'login_state.dart';
import '../../../../common/bloc_status.dart';
class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository _authRepository;

  LoginCubit({
    required AuthenticationRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginState());

  void updateUsername(String username) {
    emit(state.copyWith(username: username));
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Starting login process for username: $username');
      emit(state.copyWith(status: BlocStatus.loading));

      final user = await _authRepository.login(
        username: username,
        password: password,
      );

      debugPrint('Login successful for user: ${user.username}');
      emit(state.copyWith(
        status: BlocStatus.success,
        user: user,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      debugPrint('Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('Starting logout process');
      emit(state.copyWith(status: BlocStatus.loading));

      await _authRepository.logout();

      debugPrint('Logout successful');
      emit(const LoginState());
    } catch (e, stackTrace) {
      debugPrint('Logout error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
