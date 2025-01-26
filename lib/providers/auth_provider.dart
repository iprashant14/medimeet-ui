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
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;

  // Common method to handle authentication response
  Future<void> _handleAuthResponse(Map<String, dynamic> response) async {
    final data = response;
    final userId = data['userId']?.toString();
    final username = data['username']?.toString();
    final token = data['access_token']?.toString() ?? data['accessToken']?.toString();
    final refreshToken = data['refresh_token']?.toString() ?? data['refreshToken']?.toString();

    if (userId == null || token == null || refreshToken == null) {
      throw AuthException(
        message: 'Invalid authentication response from server',
        code: 'invalid_response',
      );
    }

    await _tokenService.saveTokens(token, refreshToken);

    _isAuthenticated = true;
    _userId = userId;
    _username = username ?? 'User';
    _email = data['email']?.toString();
    notifyListeners();
  }

  // Login method for email/password
  Future<void> login(String email, String password) async {
    try {
      _logger.info('Attempting login for user: $email');
      final loginResponse = await _authService.login(email, password);
      await _handleAuthResponse(loginResponse);
      _logger.info('Login successful for user: $_username (ID: $_userId)');
      debugPrint('🔐 Login successful - User ID: $_userId, Token stored');
    } catch (e) {
      _logger.error('Login failed', e);
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      _email = null;
      rethrow;
    }
  }

  // Google Sign In method
  Future<void> signInWithGoogle() async {
    try {
      _logger.info('Attempting Google Sign In');
      final googleResponse = await _authService.signInWithGoogle();
      await _handleAuthResponse(googleResponse);
      _logger.info('Google Sign In successful for user: $_username (ID: $_userId)');
      debugPrint('🔐 Google Sign In successful - User ID: $_userId, Token stored');
    } catch (e) {
      _logger.error('Google Sign In failed', e);
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      _email = null;
      rethrow;
    }
  }

  // Sign out method (handles both normal and Google sign out)
  Future<void> logout() async {
    try {
      _logger.info('Logging out user: $_username');
      
      // If user was signed in with Google, sign out from Google as well
      try {
        await _authService.signOutFromGoogle();
      } catch (e) {
        _logger.warning('Error during Google Sign Out: $e');
        // Continue with normal logout even if Google sign out fails
      }

      await _tokenService.clearTokens();
      _isAuthenticated = false;
      _userId = null;
      _username = null;
      _email = null;
      
      _logger.info('Logout successful');
      notifyListeners();
    } catch (e) {
      _logger.error('Logout failed', e);
      rethrow;
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

      await _tokenService.saveTokens(accessToken, refreshToken);

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
      await _tokenService.saveTokens(newTokens['accessToken'], newTokens['refreshToken']);

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
