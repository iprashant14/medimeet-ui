import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/auth/auth_exceptions.dart';

class AuthService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://localhost:8080/api/auth';

  /// Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      
      throw AuthException(
        message: 'Invalid server response',
        code: 'invalid_response',
      );
    } on DioException catch (e) {
      debugPrint('DioError: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        final errorData = e.response?.data;
        String errorMessage;
        
        if (errorData != null && errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? 'Authentication failed';
        } else {
          errorMessage = 'Invalid email or password. Please try again.';
        }
        
        throw InvalidCredentialsException(message: errorMessage);
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        String errorMessage;
        
        if (errorData != null && errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? 'Server error occurred';
          if (errorMessage.toLowerCase().contains('bad credentials')) {
            errorMessage = 'Account created but unable to auto-login. Please try logging in manually.';
          }
        } else {
          errorMessage = 'A server error occurred. Please try logging in.';
        }
        
        throw AuthException(
          message: errorMessage,
          code: 'auto_login_failed',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw AuthException(
          message: 'Connection timed out. Please check your internet connection.',
          code: 'network_error',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw AuthException(
          message: 'Unable to connect to server. Please try again later.',
          code: 'network_error',
        );
      }
      
      final errorMessage = e.response?.data?['message'] ?? 'Unable to log in. Please try again later.';
      throw AuthException(
        message: errorMessage,
        code: 'invalid_response',
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw AuthException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'unknown_error',
      );
    }
  }

  /// Signup method
  Future<Map<String, dynamic>> signup(String email, String password, String username) async {
    try {
      final response = await _dio.post(
        '$baseUrl/signup',
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      
      throw AuthException(
        message: 'Invalid server response',
        code: 'invalid_response',
      );
    } on DioException catch (e) {
      debugPrint('DioError during signup: ${e.response?.data}');
      
      if (e.response?.statusCode == 409) {
        final errorData = e.response?.data;
        String errorMessage;
        
        if (errorData != null && errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? 'User already exists';
        } else {
          errorMessage = 'A user with this email or username already exists';
        }
        
        throw AuthException(
          message: errorMessage,
          code: 'duplicate_user',
        );
      } else if (e.response?.statusCode == 500) {
        final errorData = e.response?.data;
        String errorMessage;
        
        if (errorData != null && errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? 'Server error occurred';
          if (errorMessage.toLowerCase().contains('bad credentials')) {
            errorMessage = 'Account created but unable to auto-login. Please try logging in manually.';
          }
        } else {
          errorMessage = 'A server error occurred. Please try logging in.';
        }
        
        throw AuthException(
          message: errorMessage,
          code: 'auto_login_failed',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw AuthException(
          message: 'Connection timed out. Please check your internet connection.',
          code: 'network_error',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw AuthException(
          message: 'Unable to connect to server. Please try again later.',
          code: 'network_error',
        );
      }
      
      final errorMessage = e.response?.data?['message'] ?? 'Unable to create account. Please try again later.';
      throw AuthException(
        message: errorMessage,
        code: 'signup_failed',
      );
    } catch (e) {
      debugPrint('Unexpected error during signup: $e');
      throw AuthException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'unknown_error',
      );
    }
  }

  /// Refresh Token method
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$baseUrl/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      
      throw AuthException(
        message: 'Invalid server response',
        code: 'invalid_response',
      );
    } on DioException catch (e) {
      debugPrint('DioError: ${e.response?.data}');
      
      final errorData = e.response?.data;
      String errorMessage;
      
      if (errorData != null && errorData is Map<String, dynamic>) {
        errorMessage = errorData['message'] ?? 'Token refresh failed';
      } else {
        errorMessage = 'Token refresh failed. Please try again later.';
      }
      
      throw AuthException(
        message: errorMessage,
        code: 'invalid_response',
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      throw AuthException(
        message: 'An unexpected error occurred. Please try again.',
        code: 'unknown_error',
      );
    }
  }

  /// Validate Token method
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/validate',
        data: {'token': token},
      );
      return response.data['valid'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
