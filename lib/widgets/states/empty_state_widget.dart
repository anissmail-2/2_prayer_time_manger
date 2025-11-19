import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, _) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 60,
                      color: AppTheme.primary.withOpacity(value),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            // Action button (if provided)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset empty states for common scenarios
class EmptyStates {
  /// No tasks for today
  static Widget noTasks(BuildContext context, VoidCallback onAddTask) {
    return EmptyStateWidget(
      icon: Icons.task_alt,
      title: 'No tasks yet',
      message: 'Create your first task to get started!',
      actionLabel: 'Add Task',
      onAction: onAddTask,
    );
  }

  /// All tasks completed
  static Widget allDone(BuildContext context, VoidCallback? onAddTask) {
    return EmptyStateWidget(
      icon: Icons.celebration,
      title: 'All done for today!',
      message: 'You\'ve completed all your tasks. Time to relax or plan for tomorrow.',
      actionLabel: onAddTask != null ? 'Add Tomorrow\'s Task' : null,
      onAction: onAddTask,
    );
  }

  /// No search results
  static Widget noSearchResults(BuildContext context, VoidCallback onClearSearch) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      message: 'Try different keywords or check your spelling.',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
    );
  }

  /// No spaces/projects
  static Widget noSpaces(BuildContext context, VoidCallback onCreateSpace) {
    return EmptyStateWidget(
      icon: Icons.folder_open,
      title: 'No spaces yet',
      message: 'Create a space to organize your tasks by project or context.',
      actionLabel: 'Create Space',
      onAction: onCreateSpace,
    );
  }

  /// Location not set
  static Widget noLocation(BuildContext context, VoidCallback onSetLocation) {
    return EmptyStateWidget(
      icon: Icons.location_off,
      title: 'Location not set',
      message: 'Enable location to get accurate prayer times for your city.',
      actionLabel: 'Set Location',
      onAction: onSetLocation,
    );
  }

  /// No notifications
  static Widget noNotifications(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.notifications_off,
      title: 'No notifications',
      message: 'You\'re all caught up!',
    );
  }
}
