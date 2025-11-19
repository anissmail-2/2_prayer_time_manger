import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/logger.dart';
import '../helpers/storage_helper.dart';
import 'todo_service.dart';
import 'space_service.dart';
import 'activity_service.dart';
import 'user_preferences_service.dart';
import '../../models/task.dart';
import '../../models/space.dart';
import '../../models/activity.dart';

class DataExportService {
  /// Export all app data to JSON
  static Future<Map<String, dynamic>> exportAllData() async {
    try {
      Logger.info('Starting data export', tag: 'DataExport');

      // Get all data
      final tasks = await TodoService.getTasks();
      final spaces = await SpaceService.getSpaces();
      final activities = await ActivityService.getActivities();

      // Get settings
      final isPrayerModeEnabled =
          await UserPreferencesService.isPrayerModeEnabled();
      final appTitle = await UserPreferencesService.getAppTitle();
      final locationSettings =
          await StorageHelper.getLocationSettings();
      final prayerDurations =
          await StorageHelper.getMap('prayer_durations') ?? {};

      // Create export data
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'data': {
          'tasks': tasks.map((task) => task.toJson()).toList(),
          'spaces': spaces.map((space) => space.toJson()).toList(),
          'activities': activities.map((activity) => activity.toJson()).toList(),
        },
        'settings': {
          'isPrayerModeEnabled': isPrayerModeEnabled,
          'appTitle': appTitle,
          'locationSettings': locationSettings?.toJson(),
          'prayerDurations': prayerDurations,
        },
        'metadata': {
          'totalTasks': tasks.length,
          'totalSpaces': spaces.length,
          'totalActivities': activities.length,
        },
      };

      Logger.success(
        'Data export completed: ${tasks.length} tasks, ${spaces.length} spaces, ${activities.length} activities',
        tag: 'DataExport',
      );

      return exportData;
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to export data',
        error: e,
        stackTrace: stackTrace,
        tag: 'DataExport',
      );
      rethrow;
    }
  }

  /// Save export data to file and share
  static Future<void> exportToFile() async {
    try {
      final exportData = await exportAllData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filePath = '${directory.path}/taskflow_backup_$timestamp.json';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      Logger.success('Export file created: $filePath', tag: 'DataExport');

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'TaskFlow Pro Data Export',
        text: 'Your TaskFlow Pro data backup',
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to export to file',
        error: e,
        stackTrace: stackTrace,
        tag: 'DataExport',
      );
      rethrow;
    }
  }

  /// Import data from JSON
  static Future<ImportResult> importData(String jsonString) async {
    try {
      Logger.info('Starting data import', tag: 'DataImport');

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as String?;
      if (version == null) {
        throw 'Invalid backup file: missing version';
      }

      final importData = data['data'] as Map<String, dynamic>?;
      if (importData == null) {
        throw 'Invalid backup file: missing data';
      }

      int tasksImported = 0;
      int spacesImported = 0;
      int activitiesImported = 0;
      final errors = <String>[];

      // Import spaces first (tasks may reference them)
      if (importData.containsKey('spaces')) {
        try {
          final spacesList = importData['spaces'] as List<dynamic>;
          for (final spaceJson in spacesList) {
            try {
              final space = Space.fromJson(spaceJson as Map<String, dynamic>);
              await SpaceService.createSpace(space);
              spacesImported++;
            } catch (e) {
              errors.add('Failed to import space: $e');
            }
          }
        } catch (e) {
          errors.add('Failed to import spaces: $e');
        }
      }

      // Import tasks
      if (importData.containsKey('tasks')) {
        try {
          final tasksList = importData['tasks'] as List<dynamic>;
          for (final taskJson in tasksList) {
            try {
              final task = Task.fromJson(taskJson as Map<String, dynamic>);
              await TodoService.addTask(task);
              tasksImported++;
            } catch (e) {
              errors.add('Failed to import task: $e');
            }
          }
        } catch (e) {
          errors.add('Failed to import tasks: $e');
        }
      }

      // Import activities
      if (importData.containsKey('activities')) {
        try {
          final activitiesList = importData['activities'] as List<dynamic>;
          for (final activityJson in activitiesList) {
            try {
              final activity = Activity.fromJson(activityJson as Map<String, dynamic>);
              await ActivityService.addActivity(activity);
              activitiesImported++;
            } catch (e) {
              errors.add('Failed to import activity: $e');
            }
          }
        } catch (e) {
          errors.add('Failed to import activities: $e');
        }
      }

      // Import settings
      if (data.containsKey('settings')) {
        try {
          final settings = data['settings'] as Map<String, dynamic>;

          if (settings.containsKey('isPrayerModeEnabled')) {
            await UserPreferencesService.setPrayerMode(
              settings['isPrayerModeEnabled'] as bool,
            );
          }

          if (settings.containsKey('prayerDurations')) {
            await StorageHelper.saveMap(
              'prayer_durations',
              settings['prayerDurations'] as Map<String, dynamic>,
            );
          }
        } catch (e) {
          errors.add('Failed to import settings: $e');
        }
      }

      Logger.success(
        'Data import completed: $tasksImported tasks, $spacesImported spaces, $activitiesImported activities',
        tag: 'DataImport',
      );

      return ImportResult(
        tasksImported: tasksImported,
        spacesImported: spacesImported,
        activitiesImported: activitiesImported,
        errors: errors,
      );
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to import data',
        error: e,
        stackTrace: stackTrace,
        tag: 'DataImport',
      );
      rethrow;
    }
  }

  /// Clear all app data
  static Future<void> clearAllData() async {
    try {
      Logger.info('Clearing all app data', tag: 'DataExport');

      // Clear tasks
      await StorageHelper.remove('tasks');

      // Clear spaces
      await StorageHelper.remove('spaces');

      // Clear activities
      await StorageHelper.remove('activities');

      // Clear enhanced tasks
      await StorageHelper.remove('enhanced_tasks');

      // Clear AI conversations
      await StorageHelper.remove('ai_conversations');
      await StorageHelper.remove('current_ai_conversation');

      Logger.success('All app data cleared', tag: 'DataExport');
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to clear data',
        error: e,
        stackTrace: stackTrace,
        tag: 'DataExport',
      );
      rethrow;
    }
  }
}

class ImportResult {
  final int tasksImported;
  final int spacesImported;
  final int activitiesImported;
  final List<String> errors;

  ImportResult({
    required this.tasksImported,
    required this.spacesImported,
    required this.activitiesImported,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get totalImported => tasksImported + spacesImported + activitiesImported;
}
