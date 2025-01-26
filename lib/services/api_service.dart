import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late final Dio _dio;
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        extra: {
          'withCredentials': true,
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add logging interceptor
    if (kDebugMode) {
      _dio.interceptors.clear(); // Clear any existing interceptors
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('🌐 Request: ${options.method} ${options.uri}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
                '✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('❌ Error: ${error.message}');
            return handler.next(error);
          },
        ),
      );
    }
  }

  // GET request
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: headers != null
            ? Options(
                headers: headers,
                extra: {'withCredentials': true},
              )
            : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: headers != null
            ? Options(
                headers: headers,
                extra: {'withCredentials': true},
              )
            : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: headers != null
            ? Options(
                headers: headers,
                extra: {'withCredentials': true},
              )
            : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? data, Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        options: headers != null
            ? Options(
                headers: headers,
                extra: {'withCredentials': true},
              )
            : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      
      switch (statusCode) {
        case 401:
          if (data?['code'] == 'token_expired') {
            return AuthException(
              message: 'Your session has expired',
              code: 'token_expired'
            );
          }
          return AuthException(
            message: data?['message'] ?? 'Authentication required',
            code: 'unauthorized'
          );
        
        case 403:
          return AuthException(
            message: data?['message'] ?? 'Access denied',
            code: 'unauthorized'
          );
          
        case 404:
          if (data?['code'] == 'user_not_found') {
            return AuthException(
              message: 'User account not found',
              code: 'user_not_found'
            );
          }
          return AuthException(
            message: data?['message'] ?? 'Resource not found',
            code: 'not_found'
          );
          
        case 400:
          if (data?['code'] == 'invalid_credentials') {
            return AuthException(
              message: 'Invalid username or password',
              code: 'invalid_credentials'
            );
          }
          return AuthException(
            message: data?['message'] ?? 'Invalid request',
            code: 'bad_request'
          );
      }
    }

    // Network-related errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AuthException(
        message: 'Network connection error',
        code: 'network_error'
      );
    }

    // Default error
    return AuthException(
      message: 'An unexpected error occurred',
      code: 'unknown_error'
    );
  }
}

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});
}
