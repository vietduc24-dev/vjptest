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
        super(const LoginState()) {
    // Load user data khi khởi tạo
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      debugPrint('Loading user data from local storage...');
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        debugPrint('✅ Found user data: ${user.username}');
        emit(state.copyWith(
          status: BlocStatus.success,
          user: user,
        ));
      } else {
        debugPrint('No user data found in local storage');
        emit(state.copyWith(status: BlocStatus.initial));
      }
    } catch (e) {
      debugPrint('❌ Load user data error: $e');
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

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

      debugPrint('✅ Login successful for user: ${user.username}');
      
      emit(state.copyWith(
        status: BlocStatus.success,
        user: user,
        errorMessage: null,
      ));
    } catch (e, stackTrace) {
      debugPrint('❌ Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        status: BlocStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    debugPrint('Starting logout process');
    try {
      await _authRepository.logout();
      debugPrint('Logout successful');
      emit(const LoginState());
    } catch (e) {
      debugPrint('Logout error: $e');
      // Still clear the state even if there's an error
      emit(const LoginState());
    }
  }
}
