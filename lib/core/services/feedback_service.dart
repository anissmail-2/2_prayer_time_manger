import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_service.dart';

/// Service for collecting and managing beta feedback
class FeedbackService {
  static const String _feedbackCountKey = 'feedback_count';
  static const String _lastFeedbackKey = 'last_feedback_time';

  /// Check if app is in beta mode
  static bool get isBetaMode {
    return kDebugMode || _isBetaBuild();
  }

  /// Check if this is a beta build
  static bool _isBetaBuild() {
    // You can set this via environment variable or build flavor
    // For now, checking if it's debug mode
    return kDebugMode;
  }

  /// Submit feedback
  static Future<bool> submitFeedback({
    required String email,
    required String feedbackType,
    required String message,
    Map<String, dynamic>? deviceInfo,
    String? screenshotPath,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final feedbackData = {
        'timestamp': timestamp,
        'email': email,
        'type': feedbackType,
        'message': message,
        'device_info': deviceInfo,
        'screenshot_path': screenshotPath,
        'app_version': await _getAppVersion(),
      };

      Logger.info('Feedback submitted: $feedbackType', tag: 'FeedbackService');

      // Save feedback count
      await _incrementFeedbackCount();

      // Log to Crashlytics as non-fatal (if available)
      if (FirebaseService.isConfigured && FirebaseService.isInitialized) {
        await FirebaseCrashlytics.instance.log('Feedback: $feedbackType - $message');

        // Record as non-fatal for tracking
        await FirebaseCrashlytics.instance.recordError(
          Exception('Beta Feedback: $feedbackType'),
          StackTrace.current,
          reason: message,
          fatal: false,
          information: [
            DiagnosticsProperty('email', email),
            DiagnosticsProperty('timestamp', timestamp),
            DiagnosticsProperty('device', deviceInfo.toString()),
          ],
        );
      }

      // In production, you would send this to your backend API
      // For now, just logging
      Logger.success('Feedback recorded successfully', tag: 'FeedbackService');

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to submit feedback',
        error: e,
        stackTrace: stackTrace,
        tag: 'FeedbackService',
      );
      return false;
    }
  }

  /// Submit bug report
  static Future<bool> submitBugReport({
    required String email,
    required String title,
    required String description,
    required String stepsToReproduce,
    required String expectedBehavior,
    required String actualBehavior,
    Map<String, dynamic>? deviceInfo,
    List<String>? screenshotPaths,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final bugData = {
        'timestamp': timestamp,
        'email': email,
        'title': title,
        'description': description,
        'steps_to_reproduce': stepsToReproduce,
        'expected_behavior': expectedBehavior,
        'actual_behavior': actualBehavior,
        'device_info': deviceInfo,
        'screenshots': screenshotPaths,
        'app_version': await _getAppVersion(),
      };

      Logger.info('Bug report submitted: $title', tag: 'FeedbackService');

      // Log to Crashlytics
      if (FirebaseService.isConfigured && FirebaseService.isInitialized) {
        await FirebaseCrashlytics.instance.log('Bug Report: $title');

        await FirebaseCrashlytics.instance.recordError(
          Exception('Beta Bug Report: $title'),
          StackTrace.current,
          reason: description,
          fatal: false,
          information: [
            DiagnosticsProperty('email', email),
            DiagnosticsProperty('steps', stepsToReproduce),
            DiagnosticsProperty('expected', expectedBehavior),
            DiagnosticsProperty('actual', actualBehavior),
          ],
        );
      }

      await _incrementFeedbackCount();

      Logger.success('Bug report recorded successfully', tag: 'FeedbackService');

      return true;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to submit bug report',
        error: e,
        stackTrace: stackTrace,
        tag: 'FeedbackService',
      );
      return false;
    }
  }

  /// Get total feedback count
  static Future<int> getFeedbackCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_feedbackCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increment feedback count
  static Future<void> _incrementFeedbackCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_feedbackCountKey) ?? 0;
      await prefs.setInt(_feedbackCountKey, currentCount + 1);
      await prefs.setString(_lastFeedbackKey, DateTime.now().toIso8601String());
    } catch (e) {
      Logger.error('Failed to increment feedback count', error: e, tag: 'FeedbackService');
    }
  }

  /// Get last feedback time
  static Future<DateTime?> getLastFeedbackTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFeedbackString = prefs.getString(_lastFeedbackKey);
      if (lastFeedbackString != null) {
        return DateTime.parse(lastFeedbackString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get app version
  static Future<String> _getAppVersion() async {
    // In production, use package_info_plus to get actual version
    // For now, returning a placeholder
    return '1.0.0-beta.1';
  }

  /// Track beta tester engagement
  static Future<void> trackBetaEngagement(String eventName, Map<String, dynamic>? params) async {
    try {
      if (FirebaseService.isConfigured && FirebaseService.isInitialized) {
        await FirebaseCrashlytics.instance.log('Beta Event: $eventName');
      }

      Logger.info('Beta engagement: $eventName', tag: 'FeedbackService');
    } catch (e) {
      Logger.error('Failed to track beta engagement', error: e, tag: 'FeedbackService');
    }
  }
}
