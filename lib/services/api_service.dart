import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';
import '../services/token_service.dart';

class ApiService {
  late final Dio _dio;
  final TokenService _tokenService = TokenService();
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get the access token
          final token = await _tokenService.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('Adding token to request: Bearer ${token.substring(0, 20)}...');
          } else {
            debugPrint('No token available for request');
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          debugPrint('API Error: ${error.response?.statusCode} - ${error.message}');
          if (error.response?.statusCode == 401) {
            debugPrint('Token expired, attempting refresh...');
            try {
              // Try to refresh the token
              final refreshToken = await _tokenService.getRefreshToken();
              if (refreshToken != null) {
                final response = await _dio.post(
                  '/api/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );
                
                if (response.statusCode == 200) {
                  // Save new tokens
                  await _tokenService.saveTokens(
                    response.data['accessToken'],
                    response.data['refreshToken'],
                  );
                  
                  // Retry the original request
                  final token = await _tokenService.getAccessToken();
                  error.requestOptions.headers['Authorization'] = 'Bearer $token';
                  return handler.resolve(await _dio.fetch(error.requestOptions));
                }
              }
            } catch (e) {
              debugPrint('Token refresh failed: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('API Request: ${options.method} ${options.path}');
            debugPrint('Headers: ${options.headers}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint('API Response: ${response.statusCode}');
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint('API Error: ${error.response?.statusCode} - ${error.message}');
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

  void setHeaders(Map<String, String> headers) {
    _dio.options.headers = headers;
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
            message: data?['message'] ?? 'You do not have permission to access this resource',
            code: 'forbidden'
          );
        case 404:
          return AuthException(
            message: data?['message'] ?? 'Resource not found',
            code: 'not_found'
          );
        default:
          return AuthException(
            message: data?['message'] ?? 'An error occurred',
            code: 'server_error'
          );
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return AuthException(
        message: 'Connection timed out. Please check your internet connection.',
        code: 'timeout'
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return AuthException(
        message: 'Unable to connect to the server. Please check your internet connection.',
        code: 'network_error'
      );
    }

    return AuthException(
      message: 'An unexpected error occurred',
      code: 'unknown'
    );
  }
}

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException({required this.message, required this.code});
}
