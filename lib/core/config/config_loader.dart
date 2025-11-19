/// Configuration loader that handles local and default configs
///
/// This class provides a unified interface for accessing configuration.
/// It automatically loads app_config.local.dart in development if available,
/// otherwise falls back to app_config.dart.
///
/// Configuration Priority:
/// 1. app_config.local.dart (development, git-ignored)
/// 2. app_config.dart (default/placeholder values)
///
/// Usage:
/// ```dart
/// final apiKey = ConfigLoader.geminiApiKey;
/// if (ConfigLoader.hasValidGeminiKey) {
///   // Initialize AI features
/// }
/// ```
library;

// Import local config if available, otherwise use default
// ignore_for_file: uri_does_not_exist, unused_import
import 'app_config.local.dart' if (dart.library.html) 'app_config.dart' as config;
import '../helpers/logger.dart';

class ConfigLoader {
  // Company domain configuration - easy to change
  static String get companyDomain => config.AppConfig.companyDomain;
  static String get companyName => config.AppConfig.companyName;
  static String get packageName => config.AppConfig.packageName;
  
  // API Keys
  static String get geminiApiKey => config.AppConfig.geminiApiKey;
  static String get deepgramApiKey => config.AppConfig.deepgramApiKey;
  
  // Feature flags
  static bool get enableVoiceInput => config.AppConfig.enableVoiceInput;
  static bool get enableFirebaseSync => config.AppConfig.enableFirebaseSync;
  
  // API Endpoints
  static String get prayerTimeApiBase => config.AppConfig.prayerTimeApiBase;
  
  // Validation
  static bool get hasValidGeminiKey => 
      geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && 
      geminiApiKey.isNotEmpty;
  
  static bool get hasValidDeepgramKey => 
      deepgramApiKey != 'YOUR_DEEPGRAM_API_KEY_HERE' && 
      deepgramApiKey.isNotEmpty;
  
  static void validateConfiguration() {
    // Delegate to AppConfig validation which uses Logger
    config.AppConfig.validateConfiguration();
  }
}