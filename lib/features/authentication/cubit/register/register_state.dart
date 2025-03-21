import 'package:equatable/equatable.dart';
import '../../../../models/user_model.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;
  final String? username;
  final String? companyName;
  final String? fullName;
  final String? phone;
  final String? nationality;
  final String? packageType;
  final User? user;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.username,
    this.companyName,
    this.fullName,
    this.phone,
    this.nationality,
    this.packageType,
    this.user,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    String? username,
    String? companyName,
    String? fullName,
    String? phone,
    String? nationality,
    String? packageType,
    User? user,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      username: username ?? this.username,
      companyName: companyName ?? this.companyName,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nationality: nationality ?? this.nationality,
      packageType: packageType ?? this.packageType,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        status,
        errorMessage,
        username,
        companyName,
        fullName,
        phone,
        nationality,
        packageType,
        user,
      ];
}
