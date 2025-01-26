import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/jwt_utils.dart';
import '../core/auth/auth_exceptions.dart';
import '../core/auth/auth_logger.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  final _storage = const FlutterSecureStorage();
  final _logger = AuthLogger('TokenService');

  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  /// Validates the current access token
  Future<bool> isAccessTokenValid() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) return false;
      
      return !JwtUtils.isTokenExpired(token);
    } catch (e) {
      _logger.error('Error validating access token', e);
      return false;
    }
  }

  /// Stores tokens securely
  Future<void> storeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      _logger.info('Tokens stored successfully');
    } catch (e) {
      _logger.error('Error storing tokens', e);
      throw AuthException(
        message: 'Failed to store authentication tokens',
        code: 'token_storage_failed',
      );
    }
  }

  /// Clears stored tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
      _logger.info('Tokens cleared successfully');
    } catch (e) {
      _logger.error('Error clearing tokens', e);
      throw AuthException(
        message: 'Failed to clear authentication tokens',
        code: 'token_clear_failed',
      );
    }
  }

  /// Retrieves the current access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.error('Error reading access token', e);
      return null;
    }
  }

  /// Retrieves the current refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.error('Error reading refresh token', e);
      return null;
    }
  }
}
