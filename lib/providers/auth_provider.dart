import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../core/auth/auth_logger.dart';
import '../core/auth/auth_exceptions.dart';
import '../utils/jwt_utils.dart';

class AuthProvider with ChangeNotifier {
  final _tokenService = TokenService();
  final _logger = AuthLogger('AuthProvider');
  final _authService = AuthService();

  bool _isAuthenticated = false;
  String? _userId;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get username => _username;

  // Login method
  Future<void> login(String username, String password) async {
    try {
      _logger.info('Attempting login for user: $username');
      final loginResponse = await _authService.login(username, password);

      if (loginResponse['userId'] == null) {
        throw AuthException(
            message: 'Invalid login response from server',
            code: 'invalid_response');
      }

      await _tokenService.storeTokens(
        accessToken: loginResponse['accessToken'],
        refreshToken: loginResponse['refreshToken'],
      );

      _isAuthenticated = true;
      _userId = loginResponse['userId'];
      _username = username;
      _logger.info('Login successful for user: $username (ID: $_userId)');
      debugPrint('🔐 Login successful - User ID: $_userId, Token stored');
      notifyListeners();
    } catch (e) {
      _logger.error('Login failed', e);
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
          message: 'Login failed: ${e.toString()}',
          code: 'login_failed',
          details: e);
    }
  }

  // Logout method
  Future<void> logout() async {
    _logger.info('Logging out user: $_userId');
    try {
      await _tokenService.clearTokens();
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      notifyListeners();
      _logger.info('Logout successful');
    } catch (e) {
      _logger.error('Logout failed', e);
      throw AuthException(
          message: 'Logout failed: ${e.toString()}',
          code: 'logout_failed',
          details: e);
    }
  }

  // Signup method
  Future<void> signup({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      _logger.info('Attempting signup for user: $username');
      final signupResponse = await _authService.signup(username, password, email);
      _logger.info('Signup successful for user: $username');

      // Automatically log in after successful signup
      await _tokenService.storeTokens(
        accessToken: signupResponse['accessToken'],
        refreshToken: signupResponse['refreshToken'],
      );

      _isAuthenticated = true;
      _userId = signupResponse['userId'];
      _username = username;
      _logger.info('Auto-login successful after signup - User ID: $_userId');
      notifyListeners();
    } catch (e) {
      _logger.error('Signup failed', e);
      throw AuthException(
          message: 'Signup failed: ${e.toString()}',
          code: 'signup_failed',
          details: e);
    }
  }

  // Auto-login method
  Future<void> autoLogin() async {
    try {
      _logger.info('Attempting auto-login');
      final accessToken = await _tokenService.getAccessToken();

      if (accessToken == null) {
        _logger.info('No access token found for auto-login');
        return;
      }

      if (await _tokenService.isAccessTokenValid()) {
        final userId = JwtUtils.getUserIdFromToken(accessToken);
        if (userId != null) {
          _isAuthenticated = true;
          _userId = userId;
          notifyListeners();
          _logger.info('Auto-login successful for user: $userId');
        }
      } else {
        _logger.info('Token expired, attempting refresh');
        await refreshAuthToken();
      }
    } catch (e) {
      _logger.error('Auto-login failed', e);
      await logout();
    }
  }

  // Token refresh method
  Future<void> refreshAuthToken() async {
    try {
      _logger.info('Attempting to refresh auth token');
      final refreshToken = await _tokenService.getRefreshToken();

      if (refreshToken == null) {
        throw AuthException(
            message: 'No refresh token available', code: 'no_refresh_token');
      }

      final newTokens = await _authService.refreshToken(refreshToken);
      await _tokenService.storeTokens(
        accessToken: newTokens['accessToken'],
        refreshToken: newTokens['refreshToken'],
      );

      _logger.info('Token refresh successful');
    } catch (e) {
      _logger.error('Token refresh failed', e);
      await logout();
      throw TokenRefreshException(
          message: 'Failed to refresh token: ${e.toString()}');
    }
  }
}
