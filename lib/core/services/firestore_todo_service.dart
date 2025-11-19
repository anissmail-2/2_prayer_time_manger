import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task.dart';
import 'auth_service.dart';
import 'todo_service.dart';
import 'gemini_task_assistant.dart';
import '../helpers/logger.dart';

/// Firestore-backed implementation of TodoService
/// Falls back to local storage when offline or not authenticated
class FirestoreTodoService {
  static const String _tasksKey = 'tasks';
  static const String _migrationKey = 'data_migrated_to_firestore';
  
  /// Get the Firestore tasks collection for the current user
  static CollectionReference<Map<String, dynamic>>? get _tasksCollection {
    final userId = AuthService.userId;
    if (userId == null) return null;
    
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }
  
  /// Check if we should use Firestore
  static bool get _useFirestore => AuthService.isLoggedIn && _tasksCollection != null;
  
  /// Get all tasks from Firestore
  static Future<List<Task>> getAllTasks() async {
    if (!_useFirestore) {
      throw Exception('User not authenticated');
    }
    
    try {
      // Get from Firestore
      final snapshot = await _tasksCollection!.get();
      final tasks = snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      
      // Sort by creation date (newest first)
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return tasks;
    } catch (e) {
      Logger.error('Error getting tasks from Firestore', error: e, tag: 'Firestore');
      rethrow;
    }
  }
  
  /// Add a new task
  static Future<void> addTask(Task task) async {
    Logger.debug('addTask called', tag: 'Firestore');
    Logger.debug('_useFirestore: $_useFirestore', tag: 'Firestore');
    Logger.debug('AuthService.isLoggedIn: ${AuthService.isLoggedIn}', tag: 'Firestore');
    Logger.debug('AuthService.userId: ${AuthService.userId}', tag: 'Firestore');
    Logger.debug('_tasksCollection: $_tasksCollection', tag: 'Firestore');

    if (!_useFirestore) {
      Logger.warning('Not using Firestore (not authenticated or no collection)', tag: 'Firestore');
      throw Exception('User not authenticated');
    }

    Logger.debug('User: ${AuthService.userId}', tag: 'Firestore');
    Logger.debug('Collection path: users/${AuthService.userId}/tasks', tag: 'Firestore');

    try {
      // Add to Firestore only
      Logger.debug('Adding task with ID: ${task.id}', tag: 'Firestore');
      Logger.debug('Task data: ${task.toJson()}', tag: 'Firestore');
      await _tasksCollection!.doc(task.id).set(task.toJson());
      Logger.success('Task added successfully to Firestore', tag: 'Firestore');
    } catch (e, stackTrace) {
      Logger.error('Error adding task to Firestore', error: e, stackTrace: stackTrace, tag: 'Firestore');
      rethrow;
    }
  }
  
  /// Update a task
  static Future<void> updateTask(Task updatedTask) async {
    if (!_useFirestore) {
      throw Exception('User not authenticated');
    }
    
    try {
      // Update in Firestore only
      await _tasksCollection!.doc(updatedTask.id).set(updatedTask.toJson());
    } catch (e) {
      Logger.error('Error updating task in Firestore', error: e, tag: 'Firestore');
      rethrow;
    }
  }
  
  /// Delete a task
  static Future<void> deleteTask(String taskId) async {
    if (!_useFirestore) {
      throw Exception('User not authenticated');
    }
    
    try {
      // Delete from Firestore only
      await _tasksCollection!.doc(taskId).delete();
    } catch (e) {
      Logger.error('Error deleting task from Firestore', error: e, tag: 'Firestore');
      rethrow;
    }
  }
  
  /// Toggle task completion
  static Future<void> toggleTaskCompletion(String taskId, DateTime date) async {
    final tasks = await getAllTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    // Toggle completion for the date
    List<DateTime> updatedDates = List.from(task.completedDates);
    if (task.isCompletedForDate(date)) {
      updatedDates.removeWhere((d) => Task.isSameDay(d, date));
    } else {
      updatedDates.add(date);
    }
    
    await updateTask(task.copyWith(completedDates: updatedDates));
  }
  
  /// Mark task as completed for a specific date
  static Future<void> markTaskAsCompleted(String taskId, DateTime date) async {
    final tasks = await getAllTasks();
    final task = tasks.firstWhere((t) => t.id == taskId);
    
    // Add date to completed dates if not already there
    if (!task.isCompletedForDate(date)) {
      List<DateTime> updatedDates = List.from(task.completedDates)..add(date);
      await updateTask(task.copyWith(completedDates: updatedDates));
    }
  }
  
  /// Get tasks for a specific date
  static Future<List<Task>> getTasksForDate(DateTime date) async {
    final allTasks = await getAllTasks();
    return allTasks.where((task) => task.shouldShowToday(date)).toList();
  }
  
  /// Create a task from AI suggestion
  static Future<Task> createTaskFromSuggestion(TaskSuggestion suggestion) async {
    // Parse absolute time if provided
    DateTime? absoluteTime;
    if (suggestion.absoluteTime != null) {
      final parts = suggestion.absoluteTime!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          final now = DateTime.now();
          absoluteTime = DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
    }
    
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: suggestion.title,
      description: suggestion.description ?? '',
      scheduleType: suggestion.scheduleType == 'prayerRelative' 
          ? ScheduleType.prayerRelative 
          : ScheduleType.absolute,
      absoluteTime: absoluteTime,
      relatedPrayer: suggestion.relatedPrayer != null 
          ? PrayerName.values.firstWhere(
              (p) => p.toString().split('.').last == suggestion.relatedPrayer,
              orElse: () => PrayerName.fajr,
            )
          : null,
      isBeforePrayer: suggestion.isBeforePrayer,
      minutesOffset: suggestion.minutesOffset,
      priority: suggestion.priority,
      recurrence: _parseRecurrenceType(suggestion.recurrenceType),
      weeklyDays: suggestion.weeklyDays,
      createdAt: DateTime.now(),
    );
    
    await addTask(task);
    return task;
  }
  
  /// Migrate local data to Firestore
  static Future<void> migrateLocalDataToFirestore() async {
    if (!_useFirestore) return;
    
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_migrationKey) ?? false;
    
    if (migrated) return;
    
    try {
      // Get local tasks
      final localTasks = await TodoService.getAllTasks();
      
      if (localTasks.isEmpty) {
        // No data to migrate
        await prefs.setBool(_migrationKey, true);
        return;
      }
      
      // Get existing Firestore tasks to avoid duplicates
      final firestoreTasks = await _tasksCollection!.get();
      final existingIds = firestoreTasks.docs.map((doc) => doc.id).toSet();
      
      // Migrate tasks that don't exist in Firestore
      final batch = FirebaseFirestore.instance.batch();
      int migratedCount = 0;
      
      for (final task in localTasks) {
        if (!existingIds.contains(task.id)) {
          batch.set(_tasksCollection!.doc(task.id), task.toJson());
          migratedCount++;
        }
      }
      
      if (migratedCount > 0) {
        await batch.commit();
        Logger.info('Migrated $migratedCount tasks to Firestore', tag: 'Firestore');
      }

      // Mark as migrated
      await prefs.setBool(_migrationKey, true);
    } catch (e) {
      Logger.error('Error migrating tasks to Firestore', error: e, tag: 'Firestore');
    }
  }
  
  /// Clear migration flag (useful for testing)
  static Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationKey);
  }
  
  /// Listen to real-time task updates
  static Stream<List<Task>> watchTasks() {
    if (!_useFirestore) {
      // Return a stream that emits local tasks once
      return Stream.fromFuture(TodoService.getAllTasks());
    }
    
    return _tasksCollection!
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }
  
  /// Sync local changes to Firestore (for offline-to-online sync)
  static Future<void> syncLocalChangesToFirestore() async {
    if (!_useFirestore) return;
    
    try {
      // Get local tasks
      final localTasks = await TodoService.getAllTasks();
      
      // Get Firestore tasks
      final firestoreSnapshot = await _tasksCollection!.get();
      final firestoreTasks = Map.fromEntries(
        firestoreSnapshot.docs.map((doc) => 
          MapEntry(doc.id, Task.fromJson({...doc.data(), 'id': doc.id}))
        )
      );
      
      // Find tasks that are newer locally
      for (final localTask in localTasks) {
        final firestoreTask = firestoreTasks[localTask.id];
        
        if (firestoreTask == null || 
            (localTask.updatedAt ?? localTask.createdAt).isAfter(
              firestoreTask.updatedAt ?? firestoreTask.createdAt)) {
          // Local task is newer or doesn't exist in Firestore
          await _tasksCollection!.doc(localTask.id).set(localTask.toJson());
        }
      }
      
      // Find tasks that exist in Firestore but not locally
      for (final firestoreTask in firestoreTasks.values) {
        final localExists = localTasks.any((t) => t.id == firestoreTask.id);
        if (!localExists) {
          // Add to local storage
          await TodoService.addTask(firestoreTask);
        }
      }
    } catch (e) {
      Logger.error('Error syncing tasks', error: e, tag: 'Firestore');
    }
  }
  
  static TaskRecurrence _parseRecurrenceType(String? type) {
    switch (type?.toLowerCase()) {
      case 'daily':
        return TaskRecurrence.daily;
      case 'weekly':
        return TaskRecurrence.weekly;
      case 'monthly':
        return TaskRecurrence.monthly;
      case 'yearly':
        return TaskRecurrence.yearly;
      default:
        return TaskRecurrence.once;
    }
  }
}