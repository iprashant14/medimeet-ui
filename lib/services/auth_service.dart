import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final Dio _dio = Dio(); // Assuming Dio is used for API requests
  final String baseUrl = 'http://localhost:8080/api/auth';

  /// Login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('$baseUrl/login',
          data: {'email': email, 'password': password});
      return response.data;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Signup method
  Future<Map<String, dynamic>> signup(
      String username, String password, String email) async {
    try {
      final response = await _dio.post(
        '$baseUrl/signup',
        data: {
          'username': username,
          'password': password,
          'email': email,
        },
      );
      return response.data; // Return a success message or user data
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Refresh Token method
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '$baseUrl/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      return response.data; // Assuming the API returns a new token
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Validate Token method
  Future<bool> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/validate-token',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token validation error: $e');
      return false;
    }
  }
}
