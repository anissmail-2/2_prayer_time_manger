import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/auth_wrapper.dart';
import 'core/theme/app_theme.dart';
import 'core/config/config_loader.dart';
import 'core/services/api_config_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/data_sync_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/theme_service.dart';
import 'core/helpers/logger.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handlers
  _setupErrorHandlers();

  // Run app initialization
  await _initializeApp();

  // Launch app
  runApp(const TaskFlowPro());
}

/// Set up global error handlers for uncaught exceptions
void _setupErrorHandlers() {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error(
      'Flutter error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
      tag: 'App',
    );

    // In debug mode, show red screen
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Catch errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.error(
      'Platform error: $error',
      error: error,
      stackTrace: stack,
      tag: 'App',
    );
    return true; // Handled
  };
}

/// Initialize all app services
Future<void> _initializeApp() async {
  try {
    Logger.divider();
    Logger.info('TaskFlow Pro starting...', tag: 'App');
    Logger.divider();

    // Validate configuration
    ConfigLoader.validateConfiguration();

    // Initialize API configuration (optional .env loading)
    await ApiConfigService.initialize();

    // Initialize Firebase (gracefully handles missing config)
    await FirebaseService.initialize();

    // Initialize data sync service (disabled if Firebase not configured)
    await DataSyncService.initialize();

    // Initialize notification service
    await NotificationService.initialize();

    // Schedule daily prayer notifications
    await NotificationService.schedulePrayerNotifications();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    Logger.divider();
    Logger.success('TaskFlow Pro initialized successfully', tag: 'App');
    Logger.divider();
  } catch (e, stackTrace) {
    Logger.error(
      'Failed to initialize app',
      error: e,
      stackTrace: stackTrace,
      tag: 'App',
    );
    // Don't rethrow - let app start even if some services fail
  }
}

class TaskFlowPro extends StatefulWidget {
  const TaskFlowPro({super.key});

  @override
  State<TaskFlowPro> createState() => TaskFlowProState();
}

class TaskFlowProState extends State<TaskFlowPro> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await ThemeService.getThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  // Public method to update theme mode from settings
  void updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow Pro',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,

      // Navigation
      home: const AuthWrapper(),

      // Page transitions
      builder: (context, child) {
        return MediaQuery(
          // Prevent system text scaling from breaking layouts
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
          ),
          child: child!,
        );
      },
    );
  }
}