import '../../../models/user_model.dart';
import '../../../services/api/authentication/auth_service.dart';
import '../../../services/api/authentication/vjpload/sign_in_vjpload.dart';
import '../../../services/api/authentication/vjpload/sign_up_vjpload.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthenticationRepository {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  AuthenticationRepository(this._authService);

  Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      final payload = SignInVjpload(
        username: username,
        password: password,
      );
      
      final response = await _authService.login(payload);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to login');
      }

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Lưu token vào cả secure storage và auth service
      await Future.wait([
        _storage.write(key: 'auth_token', value: token),
        _authService.setToken(token)
      ]);
      debugPrint('🔑 Token saved successfully');

      return User.fromJson(userData, token: token);
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<User> register({
    required String username,
    required String password,
    required String fullName,
    String? companyName,
    String? phone,
    String? nationality,
    String? packageType,
  }) async {
    try {
      final payload = SignUpVjpload(
        username: username,
        password: password,
        fullName: fullName,
        companyName: companyName,
        phone: phone,
        nationality: nationality,
        packageType: packageType,
      );

      final response = await _authService.register(payload);

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to register');
      }

      final token = response.data['token'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Lưu token
      await _storage.write(key: 'auth_token', value: token);

      return User.fromJson(userData, token: token);
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Xóa token khỏi secure storage
      await _storage.delete(key: 'auth_token');
      debugPrint('Token deleted, local logout completed');
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Vẫn throw để LoginCubit biết có lỗi
      throw Exception('Failed to clear local data: $e');
    }
  }

  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }
}
