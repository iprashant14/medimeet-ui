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

  /// Get the current access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) {
        _logger.debug('Retrieved access token: ${token.substring(0, 20)}...');
      } else {
        _logger.debug('No access token found');
      }
      return token;
    } catch (e) {
      _logger.error('Error reading access token', e);
      return null;
    }
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null) {
        _logger.debug('Retrieved refresh token: ${token.substring(0, 20)}...');
      } else {
        _logger.debug('No refresh token found');
      }
      return token;
    } catch (e) {
      _logger.error('Error reading refresh token', e);
      return null;
    }
  }

  /// Validates the current access token
  Future<bool> isAccessTokenValid() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token == null) {
        _logger.debug('No access token found for validation');
        return false;
      }
      
      final isValid = !JwtUtils.isTokenExpired(token);
      _logger.debug('Access token validity: $isValid');
      return isValid;
    } catch (e) {
      _logger.error('Error validating access token', e);
      return false;
    }
  }

  /// Save both access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      _logger.info('Tokens saved successfully');
      _logger.debug('Saved access token: ${accessToken.substring(0, 20)}...');
      _logger.debug('Saved refresh token: ${refreshToken.substring(0, 20)}...');
    } catch (e) {
      _logger.error('Error saving tokens', e);
      throw AuthException(
        message: 'Failed to save authentication tokens',
        code: 'token_save_error',
      );
    }
  }

  /// Clear all tokens
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
        code: 'token_clear_error',
      );
    }
  }
}
