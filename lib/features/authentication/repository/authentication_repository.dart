import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/user_model.dart';
import '../../../services/api/authentication/auth_service.dart';
import '../../../services/api/authentication/vjpload/sign_in_vjpload.dart';
import '../../../services/api/authentication/vjpload/sign_up_vjpload.dart';

class AuthenticationRepository {
  final AuthService _authService;
  final _storage = const FlutterSecureStorage();

  AuthenticationRepository(this._authService);

  Future<User?> getCurrentUser() async {
    try {
      // Lấy token từ secure storage
      final accessToken = await _storage.read(key: 'auth_token');
      if (accessToken == null) {
        debugPrint('No access token found in storage');
        return null;
      }

      // Lấy thông tin user từ API
      final response = await _authService.getCurrentUser();
      if (!response.success) {
        debugPrint('Failed to get user data from API');
        return null;
      }

      final userData = response.data['user'] as Map<String, dynamic>;
      return User.fromJson(userData, token: accessToken);
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      return null;
    }
  }

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

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      // Lưu token vào cả SecureStorage và AuthService
      await Future.wait([
        _storage.write(key: 'auth_token', value: accessToken),
        _storage.write(key: 'refresh_token', value: refreshToken),
        _authService.setToken(accessToken),
        _authService.setRefreshToken(refreshToken),
      ]);

      debugPrint('🔑 Token saved successfully');

      return User.fromJson(userData, token: accessToken);
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

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;
      final userData = response.data['user'] as Map<String, dynamic>;

      await Future.wait([
        _storage.write(key: 'auth_token', value: accessToken),
        _storage.write(key: 'refresh_token', value: refreshToken),
      ]);

      return User.fromJson(userData, token: accessToken);
    } catch (e) {
      debugPrint('❌ Register error: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    try {
      await Future.wait([
        _storage.delete(key: 'auth_token'),
        _storage.delete(key: 'refresh_token'),
      ]);
      debugPrint('🚪 Tokens cleared from secure storage');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      throw Exception('Failed to clear local data: $e');
    }
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: 'auth_token');
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: 'refresh_token');
  }
}
