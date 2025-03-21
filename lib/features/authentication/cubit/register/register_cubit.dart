import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/authentication_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthenticationRepository _authRepository;

  RegisterCubit({
    required AuthenticationRepository authRepository,
  })  : _authRepository = authRepository,
        super(const RegisterState());

  void updateUsername(String username) {
    emit(state.copyWith(username: username));
  }

  void updateCompanyName(String companyName) {
    emit(state.copyWith(companyName: companyName));
  }

  void updateFullName(String fullName) {
    emit(state.copyWith(fullName: fullName));
  }

  void updatePhone(String phone) {
    emit(state.copyWith(phone: phone));
  }

  void updateNationality(String nationality) {
    emit(state.copyWith(nationality: nationality));
  }

  void updatePackageType(String packageType) {
    emit(state.copyWith(packageType: packageType));
  }

  Future<void> register({
    required String username,
    required String password,
    required String fullName,
    String? companyName,
    String? phone,
    String? nationality,
    String? packageType,
  }) async {
    try {
      emit(state.copyWith(status: RegisterStatus.loading));

      final user = await _authRepository.register(
        username: username,
        password: password,
        fullName: fullName,
        companyName: companyName,
        phone: phone,
        nationality: nationality,
        packageType: packageType,
      );

      emit(state.copyWith(
        status: RegisterStatus.success,
        user: user,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
