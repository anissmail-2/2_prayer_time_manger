import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/logger.dart';

/// Service for managing onboarding state
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _onboardingVersionKey = 'onboarding_version';
  static const int _currentOnboardingVersion = 1;

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isComplete = prefs.getBool(_onboardingCompleteKey) ?? false;
      final version = prefs.getInt(_onboardingVersionKey) ?? 0;

      // Check if completed AND version matches
      final result = isComplete && version >= _currentOnboardingVersion;

      Logger.debug(
        'Onboarding status: complete=$isComplete, version=$version, currentVersion=$_currentOnboardingVersion',
        tag: 'OnboardingService',
      );

      return result;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to check onboarding status',
        error: e,
        stackTrace: stackTrace,
        tag: 'OnboardingService',
      );
      return false;
    }
  }

  /// Mark onboarding as complete
  static Future<void> setOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
      await prefs.setInt(_onboardingVersionKey, _currentOnboardingVersion);

      Logger.success('Onboarding marked as complete', tag: 'OnboardingService');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to mark onboarding as complete',
        error: e,
        stackTrace: stackTrace,
        tag: 'OnboardingService',
      );
    }
  }

  /// Reset onboarding (for testing or new features)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompleteKey);
      await prefs.remove(_onboardingVersionKey);

      Logger.info('Onboarding reset', tag: 'OnboardingService');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to reset onboarding',
        error: e,
        stackTrace: stackTrace,
        tag: 'OnboardingService',
      );
    }
  }

  /// Get onboarding version
  static Future<int> getOnboardingVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_onboardingVersionKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
