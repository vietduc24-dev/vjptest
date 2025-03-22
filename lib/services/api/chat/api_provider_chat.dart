import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../base/base_enpoint.dart';
import '../../base/base_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiProviderChat {
  final Dio _dio;
  final storage = const FlutterSecureStorage();
  static  String baseUrl = BaseEndpoint.baseUrl; // Update for Android emulator

  ApiProviderChat() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    debugPrint('Chat API Provider initialized with baseUrl: $baseUrl');

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth token if available
    final token = await storage.read(key: 'auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    debugPrint('Chat API Request: ${options.method} ${options.path}');
    debugPrint('Headers: ${options.headers}');
    debugPrint('Data: ${options.data}');
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    debugPrint('Chat API Response: ${response.statusCode}');
    debugPrint('Response data: ${response.data}');
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('Chat API Error: ${error.type}');
    debugPrint('Error message: ${error.message}');
    debugPrint('Error response: ${error.response?.data}');
    return handler.next(error);
  }

  Future<BaseResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        // Handle both empty array and null cases
        final data = response.data;
        if (data == null || (data is List && data.isEmpty)) {
          return BaseResponse(
            success: true,
            data: [],
            message: 'No messages found',
          );
        }

        return BaseResponse(
          success: true,
          data: data,
          message: 'Success',
        );
      }

      return BaseResponse(
        success: false,
        data: null,
        message: 'Request failed with status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  Future<BaseResponse> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BaseResponse(
          success: true,
          data: response.data,
          message: 'Success',
        );
      }

      return BaseResponse(
        success: false,
        data: null,
        message: 'Request failed with status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  BaseResponse _handleError(DioException error) {
    String message;
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timeout';
    } else if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        message = data['message'];
      } else {
        message = error.response!.statusMessage ?? 'Unknown error';
      }
    } else {
      message = error.message ?? 'An error occurred';
    }

    return BaseResponse(
      success: false,
      message: message,
      data: null,
    );
  }
} 