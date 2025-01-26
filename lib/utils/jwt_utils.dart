import 'dart:convert';

class JwtUtils {
  /// Parses a JWT token and returns its payload as a Map
  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid token format');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(resp);

    return payloadMap;
  }

  /// Checks if a token has expired
  static bool isTokenExpired(String token) {
    try {
      final jwt = parseJwt(token);
      if (!jwt.containsKey('exp')) return true;

      final expiration = DateTime.fromMillisecondsSinceEpoch(jwt['exp'] * 1000);
      return DateTime.now().isAfter(expiration);
    } catch (e) {
      return true;
    }
  }

  /// Extracts user ID from token
  static String? getUserIdFromToken(String token) {
    try {
      final jwt = parseJwt(token);
      return jwt['sub'] as String?;
    } catch (e) {
      return null;
    }
  }
}
