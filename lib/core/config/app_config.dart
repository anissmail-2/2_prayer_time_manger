/// App Configuration
///
/// IMPORTANT: Never commit real API keys to version control!
///
/// Configuration Priority (highest to lowest):
/// 1. Runtime config via ApiConfigService (stored in secure storage)
/// 2. app_config.local.dart (for development, git-ignored)
/// 3. This file (placeholder keys only)
///
/// For development:
/// 1. Copy this file to app_config.local.dart
/// 2. Add real keys to the local file
/// 3. Local file is already in .gitignore
///
/// For production:
/// Use environment variables or secure key management service
library;

import '../helpers/logger.dart';

class AppConfig {
  // Company domain - change this to your actual domain when ready for Play Store
  static const String companyDomain = 'taskflow';
  static const String companyName = 'awkati';
  
  // Full package name
  static String get packageName => 'com.$companyName.$companyDomain'; // com.awkati.taskflow
  
  // API Keys - REPLACE WITH YOUR OWN KEYS
  // These are placeholder keys that won't work
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  static const String deepgramApiKey = 'YOUR_DEEPGRAM_API_KEY_HERE';
  
  // Firebase Configuration (if needed)
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID';
  
  // Feature Flags
  static const bool enableVoiceInput = true;
  static const bool enableFirebaseSync = true; // Enable Firebase for authentication and cloud sync
  
  // API Endpoints
  static const String prayerTimeApiBase = 'https://api.aladhan.com/v1';
  
  // Validation
  static bool get hasValidGeminiKey => 
      geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && 
      geminiApiKey.isNotEmpty;
  
  static bool get hasValidDeepgramKey => 
      deepgramApiKey != 'YOUR_DEEPGRAM_API_KEY_HERE' && 
      deepgramApiKey.isNotEmpty;
  
  static void validateConfiguration() {
    Logger.divider();
    Logger.info('Validating configuration...', tag: 'Config');

    // API Keys
    Logger.config('Gemini API Key', hasValidGeminiKey);
    if (!hasValidGeminiKey) {
      Logger.warning(
        'Gemini API key not configured - AI features will not work',
        tag: 'Config',
      );
      Logger.info(
        'Please create lib/core/config/app_config.local.dart with your API key',
        tag: 'Config',
      );
    }

    Logger.config('Deepgram API Key', hasValidDeepgramKey);
    if (!hasValidDeepgramKey && enableVoiceInput) {
      Logger.warning(
        'Deepgram API key not configured - Voice input will not work',
        tag: 'Config',
      );
    }

    // Feature Flags
    Logger.config('Voice Input', enableVoiceInput);
    Logger.config('Firebase Sync', enableFirebaseSync);

    Logger.divider();
  }
}