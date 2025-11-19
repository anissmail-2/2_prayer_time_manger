import 'package:flutter/foundation.dart';
import '../services/analytics_helper.dart';

/// Professional logging system for TaskFlow Pro
///
/// Usage:
/// ```dart
/// Logger.debug('Debug message');
/// Logger.info('Info message');
/// Logger.warning('Warning message');
/// Logger.error('Error occurred', error: e, stackTrace: stackTrace);
/// ```
class Logger {
  Logger._(); // Private constructor to prevent instantiation

  /// Log levels
  static const String _debug = '🔍 DEBUG';
  static const String _info = 'ℹ️  INFO';
  static const String _warning = '⚠️  WARNING';
  static const String _error = '❌ ERROR';
  static const String _success = '✅ SUCCESS';

  /// Enable/disable logging based on build mode
  static bool get _isLoggingEnabled => kDebugMode;

  /// Debug log - only shown in debug mode
  static void debug(String message, {String? tag}) {
    if (_isLoggingEnabled) {
      final formattedMessage = _formatMessage(_debug, message, tag);
      debugPrint(formattedMessage);
    }
  }

  /// Info log - important information
  static void info(String message, {String? tag}) {
    if (_isLoggingEnabled) {
      final formattedMessage = _formatMessage(_info, message, tag);
      debugPrint(formattedMessage);
    }
  }

  /// Warning log - potential issues
  static void warning(String message, {String? tag}) {
    final formattedMessage = _formatMessage(_warning, message, tag);
    debugPrint(formattedMessage);

    // Log warnings to analytics in production
    if (!kDebugMode) {
      AnalyticsHelper.logEvent('app_warning', parameters: {
        'message': message,
        'tag': tag ?? 'unknown',
      });
    }
  }

  /// Error log - critical issues
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    final formattedMessage = _formatMessage(_error, message, tag);
    debugPrint(formattedMessage);

    if (error != null) {
      debugPrint('Error details: $error');
    }

    if (stackTrace != null) {
      debugPrint('Stack trace:\n$stackTrace');
    }

    // Log errors to analytics/crashlytics
    AnalyticsHelper.logError(
      message,
      error: error,
      stackTrace: stackTrace,
      fatal: false,
    );
  }

  /// Success log - successful operations
  static void success(String message, {String? tag}) {
    if (_isLoggingEnabled) {
      final formattedMessage = _formatMessage(_success, message, tag);
      debugPrint(formattedMessage);
    }
  }

  /// API call logging
  static void api(String endpoint, {String? method, int? statusCode}) {
    if (_isLoggingEnabled) {
      final methodStr = method ?? 'GET';
      final status = statusCode != null ? ' [$statusCode]' : '';
      debugPrint('🌐 API: $methodStr $endpoint$status');
    }
  }

  /// Navigation logging
  static void navigation(String route, {String? from}) {
    if (_isLoggingEnabled) {
      final fromStr = from != null ? ' (from: $from)' : '';
      debugPrint('📱 Navigation: $route$fromStr');
    }
  }

  /// Performance logging
  static void performance(String operation, Duration duration) {
    if (_isLoggingEnabled) {
      debugPrint('⚡ Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  /// Format message with timestamp and tag
  static String _formatMessage(String level, String message, String? tag) {
    final timestamp = DateTime.now().toString().substring(11, 23); // HH:mm:ss.SSS
    final tagStr = tag != null ? '[$tag] ' : '';
    return '$level [$timestamp] $tagStr$message';
  }

  /// Log a divider for visual separation
  static void divider() {
    if (_isLoggingEnabled) {
      debugPrint('═' * 80);
    }
  }

  /// Log app lifecycle events
  static void lifecycle(String event) {
    if (_isLoggingEnabled) {
      debugPrint('🔄 Lifecycle: $event');
    }
  }

  /// Log configuration validation
  static void config(String key, bool isValid) {
    if (_isLoggingEnabled) {
      final status = isValid ? '✅' : '❌';
      debugPrint('⚙️  Config: $key $status');
    }
  }
}
