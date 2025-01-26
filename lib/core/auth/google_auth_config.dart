import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthConfig {
  // Web Client ID from environment variables
  static String get webClientId => 
      dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');

  // Android Client ID from environment variables
  static String get androidClientId =>
      dotenv.get('GOOGLE_ANDROID_CLIENT_ID', fallback: '');

  // Required scopes for Google Sign-In
  static const List<String> scopes = [
    'email',
    'profile',
    'openid',
  ];

  // Backend API endpoint from environment variables
  static String get backendAuthEndpoint =>
      dotenv.get('BACKEND_AUTH_ENDPOINT', fallback: 'http://localhost:8080/api/auth/google');
}
