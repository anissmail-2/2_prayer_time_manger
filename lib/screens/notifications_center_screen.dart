import 'package:flutter/material.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';
import '../core/helpers/storage_helper.dart';
import '../widgets/animated_card.dart';
import '../widgets/empty_state.dart';

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
        return const Color(0xFF4CAF50); // Green for prayer
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerCard(height: 80, width: MediaQuery.of(context).size.width - 32),
                  const SizedBox(height: 12),
                  ShimmerCard(height: 80, width: MediaQuery.of(context).size.width - 32),
                  const SizedBox(height: 12),
                  ShimmerCard(height: 80, width: MediaQuery.of(context).size.width - 32),
                ],
              ),
            )
          : _notifications.isEmpty
              ? EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No notifications yet',
                  message: 'Your notifications will appear here when you receive them',
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
                          gradient: AppThemeExtensions.errorGradient,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) {
                        _deleteNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Notification deleted'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      },
                      child: AnimatedCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        gradient: !notification.isRead
                            ? LinearGradient(
                                colors: [
                                  AppTheme.primary.withOpacity(0.05),
                                  AppTheme.primary.withOpacity(0.02),
                                ],
                              )
                            : null,
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getColorForType(notification.type),
                                  _getColorForType(notification.type).withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color: _getColorForType(notification.type).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getIconForType(notification.type),
                              color: Colors.white,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getTimeAgo(notification.timestamp),
                                    style: AppTheme.labelSmall.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: !notification.isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
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
