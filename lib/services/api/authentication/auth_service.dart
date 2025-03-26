import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../api_provider.dart';

import '../../base/base_reponse.dart';
import 'authentication_endpoint.dart';
import 'vjpload/sign_in_vjpload.dart';
import 'vjpload/sign_up_vjpload.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _refreshTokenKey = 'refresh_token';

  static AuthService? _instance;
  SharedPreferences? _prefs;
  ApiProvider? _apiProvider;

  AuthService([this._apiProvider]) {
    _initPrefs();
  }

  void updateApiProvider(ApiProvider apiProvider) {
    _apiProvider = apiProvider;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // API calls
  Future<BaseResponse> getCurrentUser() async {
    _checkApiProvider();
    try {
      debugPrint('🔍 Getting current user...');
      final response = await _apiProvider!.get(AuthenticationEndpoint.currentUser);
      debugPrint('✅ Got current user response: ${response.data}');
      return response; // ApiProvider đã parse thành BaseResponse rồi
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      rethrow;
    }
  }

  Future<BaseResponse> login(SignInVjpload payload) async {
    _checkApiProvider();
    final response = await _apiProvider!.post(
      AuthenticationEndpoint.login,
      data: payload.toJson(),
    );

    if (response.success) {
      // Lưu token và thông tin user khi đăng nhập thành công
      final data = response.data as Map<String, dynamic>;
      await saveAuthData(
        token: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        userId: data['user']['id'].toString(),
        username: data['user']['username'] as String,
      );
    }

    return response;
  }

  Future<BaseResponse> register(SignUpVjpload payload) async {
    _checkApiProvider();
    return _apiProvider!.post(
      AuthenticationEndpoint.register,
      data: payload.toJson(),
    );
  }

  Future<BaseResponse> logout() async {
    _checkApiProvider();
    final response = await _apiProvider!.post(AuthenticationEndpoint.logout);
    if (response.success) {
      await clearAuthData();
    }
    return response;
  }

  Future<BaseResponse> refreshAccessToken() async {
    _checkApiProvider();
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await _apiProvider!.post(
      AuthenticationEndpoint.refreshToken,
      data: {
        'refreshToken': refreshToken,
      },
    );

    if (response.success) {
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String?;

      // Lưu access token mới
      await setToken(newAccessToken);

      // Nếu server trả về refresh token mới thì lưu luôn
      if (newRefreshToken != null) {
        await setRefreshToken(newRefreshToken);
      }
    }

    return response;
  }

  void _checkApiProvider() {
    if (_apiProvider == null) {
      throw Exception('ApiProvider not initialized');
    }
  }

  // Token management
  Future<void> setRefreshToken(String refreshToken) async {
    await _prefs?.setString(_refreshTokenKey, refreshToken);
  }
  Future<void> setToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }
  String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
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
    required String refreshToken,
    required String userId,
    required String username,
  }) async {
    await Future.wait([
      setToken(token),
      setRefreshToken(refreshToken),
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
      _prefs?.remove(_refreshTokenKey),
    ].whereType<Future>());
  }

  // Check if user is logged in
  bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
} 