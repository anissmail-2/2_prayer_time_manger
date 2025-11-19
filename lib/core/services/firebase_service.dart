import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../helpers/logger.dart';
import '../config/app_config.dart';

/// Service for managing Firebase initialization and instances
class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseAnalytics? _analytics;
  static FirebaseCrashlytics? _crashlytics;
  static bool _isInitialized = false;

  /// Check if Firebase is supported on this platform
  static bool get isSupported {
    try {
      return Platform.isAndroid || Platform.isIOS || kIsWeb;
    } catch (e) {
      return false;
    }
  }

  /// Check if Firebase is configured (has necessary configuration files)
  static bool get isConfigured => AppConfig.enableFirebaseSync;

  /// Check if Firebase is initialized and ready to use
  static bool get isInitialized => _isInitialized;

  /// Initialize Firebase services
  static Future<void> initialize() async {
    // Skip if Firebase is disabled
    if (!isConfigured) {
      Logger.info('Firebase sync is disabled in configuration', tag: 'Firebase');
      return;
    }

    // Skip Firebase initialization on unsupported platforms
    if (!isSupported) {
      Logger.info('Firebase is not supported on this platform', tag: 'Firebase');
      return;
    }

    try {
      // Initialize Firebase with default options
      // Note: This requires google-services.json (Android) or GoogleService-Info.plist (iOS)
      await Firebase.initializeApp();

      // Initialize services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Configure Crashlytics
      if (!kDebugMode) {
        // Enable crash collection in release mode
        await _crashlytics!.setCrashlyticsCollectionEnabled(true);

        // Pass all uncaught errors to Crashlytics
        FlutterError.onError = _crashlytics!.recordFlutterError;
      }

      // Set Firestore settings for offline support
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _isInitialized = true;
      Logger.success('Firebase initialized successfully', tag: 'Firebase');
    } catch (e) {
      Logger.warning(
        'Firebase initialization failed - app will work with local storage only',
        tag: 'Firebase',
      );
      Logger.debug('Firebase error details: $e', tag: 'Firebase');
      // Don't rethrow - app should work without Firebase
    }
  }
  
  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _auth!;
  }
  
  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _firestore!;
  }
  
  /// Get Analytics instance
  static FirebaseAnalytics get analytics {
    if (_analytics == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _analytics!;
  }
  
  /// Get Crashlytics instance
  static FirebaseCrashlytics get crashlytics {
    if (_crashlytics == null) {
      throw Exception('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return _crashlytics!;
  }
  
  /// Get current user
  static User? get currentUser => _auth?.currentUser;
  
  /// Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  /// Get current user ID
  static String? get currentUserId => currentUser?.uid;
  
  /// Get Firebase Auth instance (nullable)
  static FirebaseAuth? get authNullable => _auth;
  
  /// Get Firestore instance (nullable)
  static FirebaseFirestore? get firestoreNullable => _firestore;
  
  /// Sign out
  static Future<void> signOut() async {
    await auth.signOut();
  }
}