import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/auth/auth_exceptions.dart';
import '../core/auth/google_auth_config.dart';

// Handles all authentication related operations including Google Sign-In
class AuthService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8080/api/auth';  // Backend is always on 8080
  
  // Initialize GoogleSignIn with web client ID for web platform
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? GoogleAuthConfig.webClientId : null,
    scopes: GoogleAuthConfig.scopes,
    signInOption: SignInOption.standard,
  );

  // Set up HTTP client with default headers
  AuthService() : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    _dio.options.validateStatus = (status) => status! < 500;
    
    if (kIsWeb) {
      _dio.options.extra = {
        'withCredentials': true,
      };
      // Initialize Google Sign In silently
      _googleSignIn.signInSilently().then((_) {
        debugPrint('Silent sign-in initialized');
      }).catchError((error) {
        debugPrint('Silent sign-in error: $error');
      });
    }
  }

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

  /// Google Sign In
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint('Starting Google Sign In');
      
      // Force a fresh sign in
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
      
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        throw AuthException(
          message: 'Google Sign In was cancelled',
          code: 'sign_in_cancelled',
        );
      }

      debugPrint('Got Google account: ${account.email}');

      // Get authentication with timeout
      final GoogleSignInAuthentication auth = await account.authentication.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw AuthException(
            message: 'Authentication timed out',
            code: 'auth_timeout',
          );
        },
      );
      
      debugPrint('Got authentication object');
      debugPrint('Access token present: ${auth.accessToken != null}');
      debugPrint('ID token present: ${auth.idToken != null}');
      
      if (auth.accessToken == null) {
        throw AuthException(
          message: 'Failed to get access token',
          code: 'no_access_token',
        );
      }

      debugPrint('Got Access Token: ${auth.accessToken?.substring(0, 20)}...');
      
      // Get user info from Google Sign In
      final Map<String, dynamic> userData = {
        'email': account.email,
        'name': account.displayName,
        'accessToken': auth.accessToken,
      };

      debugPrint('Sending Google auth request...');
      
      final response = await _dio.post(
        '/google',
        data: userData,
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('Successfully authenticated with backend');
        return Map<String, dynamic>.from(response.data);
      }

      debugPrint('Backend error: ${response.statusCode} - ${response.data}');
      throw AuthException(
        message: response.data?['message'] ?? 'Invalid server response',
        code: 'invalid_response',
      );
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
      throw AuthException(
        message: 'Failed to sign out from Google',
        code: 'google_sign_out_failed',
      );
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      final errorData = e.response?.data;
      String errorMessage = errorData?['message'] ?? 'Authentication failed';
      throw AuthException(
        message: errorMessage,
        code: 'unauthorized',
      );
    } else if (e.response?.statusCode == 400) {
      final errorData = e.response?.data;
      String errorMessage = errorData?['message'] ?? 'Invalid request';
      throw AuthException(
        message: errorMessage,
        code: 'invalid_request',
      );
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw AuthException(
        message: 'Connection timeout. Please try again.',
        code: 'timeout',
      );
    } else {
      throw AuthException(
        message: 'An unexpected error occurred',
        code: 'unknown',
      );
    }
  }
}
