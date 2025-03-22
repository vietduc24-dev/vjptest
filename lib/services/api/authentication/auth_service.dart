import 'package:shared_preferences/shared_preferences.dart';
import '../api_provider.dart';

import '../../base/base_reponse.dart';
import 'authentication_endpoint.dart';
import 'vjpload/sign_in_vjpload.dart';
import 'vjpload/sign_up_vjpload.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';

  static AuthService? _instance;
  SharedPreferences? _prefs;
  final ApiProvider _apiProvider;

  AuthService(this._apiProvider) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // API calls
  Future<BaseResponse> login(SignInVjpload payload) async {
    final response = await _apiProvider.post(
      AuthenticationEndpoint.login,
      data: payload.toJson(),
    );

    if (response.success) {
      // Lưu token và thông tin user khi đăng nhập thành công
      final data = response.data as Map<String, dynamic>;
      await saveAuthData(
        token: data['token'] as String,
        userId: data['user']['id'].toString(),
        username: data['user']['username'] as String,
      );
    }

    return response;
  }

  Future<BaseResponse> register(SignUpVjpload payload) async {
    return _apiProvider.post(
      AuthenticationEndpoint.register,
      data: payload.toJson(),
    );
  }

  Future<BaseResponse> logout() async {
    final response = await _apiProvider.post(AuthenticationEndpoint.logout);
    if (response.success) {
      await clearAuthData();
    }
    return response;
  }

  Future<BaseResponse> refreshToken(String refreshToken) async {
    final response = await _apiProvider.post(
      AuthenticationEndpoint.refreshToken,
      data: {
        'refresh_token': refreshToken,
      },
    );

    if (response.success) {
      final data = response.data as Map<String, dynamic>;
      await setToken(data['token'] as String);
    }

    return response;
  }

  // Token management
  Future<void> setToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  // User ID management
  Future<void> setUserId(String userId) async {
    await _prefs?.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _prefs?.getString(_userIdKey);
  }

  // Username management
  Future<void> setUsername(String username) async {
    await _prefs?.setString(_usernameKey, username);
  }

  String? getUsername() {
    return _prefs?.getString(_usernameKey);
  }

  // Save all auth data at once
  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String username,
  }) async {
    await Future.wait([
      setToken(token),
      setUserId(userId),
      setUsername(username),
    ]);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await Future.wait([
      _prefs?.remove(_tokenKey),
      _prefs?.remove(_userIdKey),
      _prefs?.remove(_usernameKey),
    ].whereType<Future>());
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
} 