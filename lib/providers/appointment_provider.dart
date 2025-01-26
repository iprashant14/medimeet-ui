import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Secure storage
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  final _secureStorage = const FlutterSecureStorage();
  static const _userIdKey = 'userId';
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  /// Login method
  Future<void> login(String username, String password) async {
    try {
      final loginResponse = await AuthService().login(username, password);

      // Validate the response
      if (loginResponse['userId'] == null) {
        throw Exception('Invalid login response: $loginResponse');
      }

      // Save tokens securely
      await _secureStorage.write(
          key: _userIdKey, value: loginResponse['userId']);
      if (loginResponse['accessToken'] != null) {
        await _secureStorage.write(
            key: _accessTokenKey, value: loginResponse['accessToken']);
      }
      if (loginResponse['refreshToken'] != null) {
        await _secureStorage.write(
            key: _refreshTokenKey, value: loginResponse['refreshToken']);
      }

      _isAuthenticated = true;
      _userId = loginResponse['userId'];
      _accessToken = loginResponse['accessToken'];
      _refreshToken = loginResponse['refreshToken'];
      notifyListeners();
    } catch (e) {
      _isAuthenticated = false;
      _userId = null;
      debugPrint('Login failed: $e');
      rethrow;
    }
  }

  /// Logout method
  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _accessToken = null;
    _refreshToken = null;

    try {
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('Logout failed: $e');
    }

    notifyListeners();
  }

  /// Signup method
  Future<void> signup({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      await AuthService().signup(username, password, email);
    } catch (e) {
      debugPrint('Signup failed: $e');
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  /// Auto-login method (check stored credentials)
  Future<void> autoLogin() async {
    try {
      final savedUserId = await _secureStorage.read(key: _userIdKey);
      final savedAccessToken = await _secureStorage.read(key: _accessTokenKey);

      if (savedUserId != null && savedAccessToken != null) {
        _isAuthenticated = true;
        _userId = savedUserId;
        _accessToken = savedAccessToken;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
      _isAuthenticated = false;
      _userId = null;
      _accessToken = null;
    }
  }

  /// Refresh token method (renamed to refreshAuthToken)
  Future<void> refreshAuthToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        final newTokens = await AuthService().refreshToken(refreshToken);
        await _secureStorage.write(
            key: _accessTokenKey, value: newTokens['accessToken']);
        await _secureStorage.write(
            key: _refreshTokenKey, value: newTokens['refreshToken']);

        // Update the current tokens
        _accessToken = newTokens['accessToken'];
        _refreshToken = newTokens['refreshToken'];
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      logout(); // Log out if token refresh fails
    }
  }
}
