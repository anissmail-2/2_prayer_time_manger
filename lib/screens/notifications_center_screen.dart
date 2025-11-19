import 'package:flutter/material.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/theme/app_theme.dart';
import '../core/helpers/storage_helper.dart';

class NotificationsCenterScreen extends StatefulWidget {
  const NotificationsCenterScreen({super.key});

  @override
  State<NotificationsCenterScreen> createState() =>
      _NotificationsCenterScreenState();
}

class _NotificationsCenterScreenState extends State<NotificationsCenterScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('notifications_center');
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load notification history from storage
      final notificationsList =
          await StorageHelper.getList('notification_history') ?? [];
      _notifications = notificationsList
          .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load notifications',
        error: e,
        stackTrace: stackTrace,
        tag: 'NotificationsCenter',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await StorageHelper.remove('notification_history');
      setState(() {
        _notifications.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to clear notifications',
        error: e,
        stackTrace: stackTrace,
        tag: 'NotificationsCenter',
      );
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      _notifications.removeWhere((n) => n.id == id);
      await StorageHelper.saveList(
        'notification_history',
        _notifications.map((n) => n.toJson()).toList(),
      );

      setState(() {});
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to delete notification',
        error: e,
        stackTrace: stackTrace,
        tag: 'NotificationsCenter',
      );
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'task':
        return Icons.check_circle_outline;
      case 'prayer':
        return Icons.access_time;
      case 'reminder':
        return Icons.notifications_active;
      case 'sync':
        return Icons.cloud_sync;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'task':
        return AppTheme.primary;
      case 'prayer':
        return AppTheme.prayerColors['fajr'] ?? AppTheme.primary;
      case 'reminder':
        return AppTheme.warning;
      case 'sync':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppTheme.textPrimary),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notifications'),
                    content: const Text(
                      'Are you sure you want to clear all notifications?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllNotifications();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: AppTheme.textSecondary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your notifications will appear here',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? Colors.white
                              : AppTheme.primary.withOpacity(0.05),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(
                            color: notification.isRead
                                ? AppTheme.borderLight
                                : AppTheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor:
                                _getColorForType(notification.type)
                                    .withOpacity(0.1),
                            child: Icon(
                              _getIconForType(notification.type),
                              color: _getColorForType(notification.type),
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (notification.body.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  notification.body,
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                _getTimeAgo(notification.timestamp),
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Mark as read
                            if (!notification.isRead) {
                              setState(() {
                                notification.isRead = true;
                              });
                              StorageHelper.saveList(
                                'notification_history',
                                _notifications.map((n) => n.toJson()).toList(),
                              );
                            }

                            // Handle notification tap (navigate to relevant screen)
                            // TODO: Implement navigation based on notification type/payload
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // task, prayer, reminder, sync, etc.
  final DateTime timestamp;
  bool isRead;
  final Map<String, dynamic>? payload;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
    };
  }
}
