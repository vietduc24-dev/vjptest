
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../base/base_reponse.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'authentication/auth_service.dart';

class ApiProvider {
  late Dio _dio;
  late SharedPreferences _prefs;
  final AuthService _authService;

  // Use same keys as AuthService
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiProvider._internal(this._authService);

  // Factory constructor để dùng await khi khởi tạo
  static Future<ApiProvider> create(AuthService authService) async {
    final provider = ApiProvider._internal(authService);
    provider._prefs = await SharedPreferences.getInstance();
    provider._initDio();
    return provider;
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: kDebugMode ? debugPrint : null,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 4),
          Duration(seconds: 8),
        ],
        retryableExtraStatuses: {401, 403},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          debugPrint(obj.toString());
        },
      ));
    }
  }

  Future<void> _onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Nếu đang gọi login hoặc register thì không cần đính token
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    final token = _prefs.getString(_tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    } else {
      debugPrint('⚠️ No token found for authenticated request');
      return handler.next(options);
    }
  }

  Future<void> _onResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) async {
    return handler.next(response);
  }

  Future<void> _onError(
      DioException error,
      ErrorInterceptorHandler handler,
      ) async {
    if (kDebugMode) {
      debugPrint('❌ API Error: ${error.type} - ${error.message}');
      debugPrint('❌ Status code: ${error.response?.statusCode}');
    }

    // Handle both 401 and 403 status codes
    if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
      final errorCode = error.response?.data is Map ? error.response?.data['code'] : null;
      
      if (error.response?.statusCode == 401 || errorCode == 'TOKEN_EXPIRED') {
        try {
          // Refresh token
          final response = await _authService.refreshAccessToken();
          
          if (response.success) {
            // Gửi lại request cũ với token mới
            final newAccessToken = _authService.getToken();
            final retryRequest = await _dio.request(
              error.requestOptions.path,
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
              options: Options(
                method: error.requestOptions.method,
                headers: {
                  ...?error.requestOptions.headers,
                  'Authorization': 'Bearer $newAccessToken',
                },
              ),
            );

            return handler.resolve(retryRequest);
          }
        } catch (e) {
          debugPrint('❌ Token refresh failed');
          // Clear auth data on refresh failure
          await _authService.clearAuthData();
          return handler.reject(error);
        }
      }
    }

    return handler.next(error);
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      
      // Always convert to BaseResponse
      if (response.data is Map<String, dynamic>) {
        return BaseResponse.fromJson(response.data);
      } else {
        return BaseResponse(
          success: true,
          message: 'Success',
          data: response.data,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return BaseResponse(
          success: false,
          message: 'Connection timeout. Please check your internet connection.',
          data: null,
        );
      }
      
      if (e.response?.data is Map<String, dynamic>) {
        return BaseResponse.fromJson(e.response!.data);
      }
      
      return BaseResponse(
        success: false,
        message: e.message ?? 'An error occurred',
        data: null,
      );
    } catch (e) {
      return BaseResponse(
        success: false,
        message: e.toString(),
        data: null,
      );
    }
  }

  Future<BaseResponse> post(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? params,
      }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: params,
      );
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BaseResponse> put(
      String endpoint, {
        dynamic data,
        Map<String, dynamic>? params,
      }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: params,
      );
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<BaseResponse> delete(
      String endpoint, {
        Map<String, dynamic>? params,
      }) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: params);
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Không thể kết nối đến server. Vui lòng thử lại sau.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    }

    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return Exception(data['message']);
      }
      return Exception(error.response!.statusMessage ?? 'Lỗi không xác định');
    }

    return Exception('Đã có lỗi xảy ra. Vui lòng thử lại sau.');
  }
}