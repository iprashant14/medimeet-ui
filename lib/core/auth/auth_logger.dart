import 'package:logging/logging.dart';

/// Custom logger for authentication-related operations
class AuthLogger {
  final Logger logger;
  static bool _isInitialized = false;

  AuthLogger(String name) : logger = Logger(name) {
    _initializeLogging();
  }

  static void _initializeLogging() {
    if (_isInitialized) return;
    
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      // In development, print to console
      print('${record.level.name}: ${record.time}: ${record.message}');
      
      // TODO: In production, send to proper logging service
      // Example: Firebase Crashlytics, Sentry, etc.
    });
    
    _isInitialized = true;
  }

  void debug(String message) {
    logger.fine(message);
  }

  void info(String message) {
    logger.info(message);
  }

  void warning(String message) {
    logger.warning(message);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    logger.severe(message, error, stackTrace);
  }
}
