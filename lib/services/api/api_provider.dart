import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../base/base_enpoint.dart';
import '../base/base_reponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class ApiProvider {
  late Dio _dio;
  final storage = const FlutterSecureStorage();

  ApiProvider() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BaseEndpoint.baseUrl,
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
    final token = await storage.read(key: 'auth_token');
    debugPrint('🔑 Token from storage: $token');
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint('📤 Request headers: ${options.headers}');
    } else {
      debugPrint('⚠️ No token found in storage');
    }
    return handler.next(options);
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
      debugPrint('API Error: ${error.type}');
      debugPrint('Error message: ${error.message}');
      debugPrint('Error response: ${error.response?.data}');
    }

    if (error.response?.statusCode == 401) {
      await storage.delete(key: 'auth_token');
    }
    return handler.next(error);
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      if (response.data is List) return response.data;
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
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
    if (kDebugMode) {
      debugPrint('Handling error: ${error.type}');
      debugPrint('Error response data: ${error.response?.data}');
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout');
    }

    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return Exception(data['message']);
      }
      return Exception(error.response!.statusMessage);
    }

    return Exception('An error occurred');
  }
}
