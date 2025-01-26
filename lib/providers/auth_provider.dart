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
  Future<void> login(String email, String password) async {
    try {
      _logger.info('Attempting login for user: $email');
      final loginResponse = await _authService.login(email, password);

      final userId = loginResponse['userId']?.toString();
      final username = loginResponse['username']?.toString();
      final accessToken = loginResponse['accessToken']?.toString();
      final refreshToken = loginResponse['refreshToken']?.toString();

      if (userId == null || accessToken == null || refreshToken == null) {
        throw AuthException(
          message: 'Invalid login response from server',
          code: 'invalid_response',
        );
      }

      await _tokenService.storeTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _isAuthenticated = true;
      _userId = userId;
      _username = username ?? 'User'; // Use username from response or fallback to 'User'
      _logger.info('Login successful for user: $_username (ID: $_userId)');
      debugPrint('🔐 Login successful - User ID: $_userId, Token stored');
      notifyListeners();
    } catch (e) {
      _logger.error('Login failed', e);
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      rethrow;
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
  Future<void> signup(String email, String password, String username) async {
    try {
      _logger.info('Attempting signup for user: $email');
      final signupResponse = await _authService.signup(email, password, username);

      final userId = signupResponse['userId']?.toString();
      final accessToken = signupResponse['accessToken']?.toString();
      final refreshToken = signupResponse['refreshToken']?.toString();
      final responseUsername = signupResponse['username']?.toString();

      if (userId == null || accessToken == null || refreshToken == null) {
        throw AuthException(
          message: 'Invalid signup response from server',
          code: 'invalid_response',
        );
      }

      await _tokenService.storeTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _isAuthenticated = true;
      _userId = userId;
      _username = responseUsername ?? username;  // Use response username or fallback to provided username
      _logger.info('Signup successful for user: $_username (ID: $_userId)');
      debugPrint('🔐 Signup successful - User ID: $_userId, Token stored');
      notifyListeners();
    } catch (e) {
      _logger.error('Signup failed', e);
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      rethrow;
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

  Future<void> refreshToken() async {
    try {
      _logger.info('Refreshing tokens');
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException(
          code: 'refresh-token-missing',
          message: 'No refresh token available'
        );
      }
      await _authService.refreshToken(refreshToken);
      _logger.info('Tokens refreshed successfully');
    } catch (e) {
      _logger.error('Failed to refresh token: ${e.toString()}');
      throw AuthException(
          code: 'refresh-token-failed',
          message: 'Failed to refresh token: ${e.toString()}');
    }
  }
}
