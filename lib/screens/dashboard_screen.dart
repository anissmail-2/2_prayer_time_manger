import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/services/todo_service.dart';
import '../core/services/prayer_time_service.dart';
import '../core/services/user_preferences_service.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';
import '../models/task.dart';
import '../widgets/task_details_dialog.dart';
import '../widgets/animated_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/modern_dashboard_header.dart';
import 'add_edit_item_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, String> _prayerTimes = {};
  List<TaskWithTime> _todayTasks = [];
  bool _isLoading = true;
  String? _nextPrayer;
  String? _nextPrayerTime;
  Duration? _timeToNextPrayer;
  bool _isPrayerModeEnabled = true; // Default to prayer mode

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('dashboard');
    _loadPrayerMode();
    _loadData();
    // Update timer every minute
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _startTimer();
      }
    });
  }

  Future<void> _loadPrayerMode() async {
    final enabled = await UserPreferencesService.isPrayerModeEnabled();
    if (mounted) {
      setState(() {
        _isPrayerModeEnabled = enabled;
      });
    }
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      _updateNextPrayer();
      return true;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (_isPrayerModeEnabled) {
        _prayerTimes = await PrayerTimeService.getPrayerTimes();
        _todayTasks = await TodoService.getUpcomingTasksWithTimes(_prayerTimes);
        _updateNextPrayer();
      } else {
        // In productivity mode, just load tasks without prayer times
        _todayTasks = await TodoService.getUpcomingTasksWithTimes({});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _updateNextPrayer() {
    if (_prayerTimes.isEmpty) return;
    
    final now = DateTime.now();
    final currentTime = TimeOfDay.now();
    
    String? nextPrayerName;
    TimeOfDay? nextPrayerTimeOfDay;
    
    for (final entry in _prayerTimes.entries) {
      if (entry.key == 'Sunrise') continue;
      
      final parts = entry.value.split(':');
      if (parts.length != 2) continue;
      
      final prayerTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
      
      if (_isTimeAfter(prayerTime, currentTime)) {
        nextPrayerName = entry.key;
        nextPrayerTimeOfDay = prayerTime;
        break;
      }
    }
    
    // If no prayer found today, get first prayer tomorrow
    if (nextPrayerName == null) {
      nextPrayerName = 'Fajr';
      final fajrTime = _prayerTimes['Fajr']!.split(':');
      nextPrayerTimeOfDay = TimeOfDay(
        hour: int.parse(fajrTime[0]),
        minute: int.parse(fajrTime[1]),
      );
    }
    
    if (nextPrayerTimeOfDay != null) {
      final nextDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        nextPrayerTimeOfDay.hour,
        nextPrayerTimeOfDay.minute,
      );
      
      // If prayer time has passed today, add a day
      Duration diff = nextDateTime.difference(now);
      if (diff.isNegative) {
        diff = nextDateTime.add(const Duration(days: 1)).difference(now);
      }
      
      setState(() {
        _nextPrayer = nextPrayerName;
        _nextPrayerTime = _prayerTimes[nextPrayerName];
        _timeToNextPrayer = diff;
      });
    }
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute > time2.minute) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern Header with gradient and prayer time
                    if (_isPrayerModeEnabled)
                      ModernDashboardHeader(
                        userName: 'User',
                        greeting: _getGreeting(),
                        nextPrayer: _nextPrayer,
                        timeToNextPrayer: _timeToNextPrayer != null
                            ? _formatTimeRemaining(_timeToNextPrayer!)
                            : null,
                      )
                    else
                      _buildSimpleHeader(),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.space24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsCards(),
                          const SizedBox(height: AppTheme.space24),
                          _buildTodayTasksSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditItemScreen(prayerTimes: _prayerTimes),
            ),
          );
          if (result == true) {
            await _loadData();
          }
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Shimmer for header
          const ShimmerCard(height: 200, width: double.infinity),
          Padding(
            padding: const EdgeInsets.all(AppTheme.space24),
            child: Column(
              children: [
                // Shimmer for stats
                Row(
                  children: [
                    Expanded(child: ShimmerCard(height: 120)),
                    const SizedBox(width: AppTheme.space16),
                    Expanded(child: ShimmerCard(height: 120)),
                    const SizedBox(width: AppTheme.space16),
                    Expanded(child: ShimmerCard(height: 120)),
                  ],
                ),
                const SizedBox(height: AppTheme.space24),
                // Shimmer for tasks
                ShimmerCard(height: 80),
                const SizedBox(height: AppTheme.space12),
                ShimmerCard(height: 80),
                const SizedBox(height: AppTheme.space12),
                ShimmerCard(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppThemeExtensions.primaryGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                'User',
                style: AppTheme.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.space8),
              Text(
                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatTimeRemaining(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours hr $minutes min';
    } else {
      return '$minutes min';
    }
  }


  Widget _buildStatsCards() {
    final completedToday = _todayTasks.where((t) => t.task.isCompletedForDate(DateTime.now())).length;
    final totalToday = _todayTasks.length;
    final pendingTasks = totalToday - completedToday;
    final progress = totalToday > 0 ? completedToday / totalToday : 0.0;

    return Row(
      children: [
        Expanded(
          child: TrendingStatCard(
            icon: Icons.check_circle,
            title: 'Completed',
            value: completedToday.toString(),
            trend: totalToday > 0 ? '${(progress * 100).toStringAsFixed(0)}%' : '0%',
            isTrendingUp: progress >= 0.5,
            gradient: AppThemeExtensions.successGradient,
          ),
        ),
        const SizedBox(width: AppTheme.space16),
        Expanded(
          child: CompactStatCard(
            icon: Icons.pending_actions,
            label: 'Pending',
            value: pendingTasks.toString(),
            iconColor: AppTheme.warning,
          ),
        ),
        const SizedBox(width: AppTheme.space16),
        Expanded(
          child: ProgressStatCard(
            icon: Icons.task_alt,
            title: 'Daily Goal',
            progress: progress,
            valueText: '$completedToday of $totalToday',
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTasksSection() {
    final upcomingTasks = _todayTasks
        .where((t) => !t.task.isCompletedForDate(DateTime.now()))
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Tasks',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to tasks screen
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space16),
        if (upcomingTasks.isEmpty)
          CompactEmptyState(
            icon: Icons.task_alt,
            message: 'No pending tasks for today',
            actionLabel: 'Add Task',
            onAction: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditItemScreen(prayerTimes: _prayerTimes),
                ),
              );
              if (result == true) {
                await _loadData();
              }
            },
          )
        else
          ...upcomingTasks.map((taskWithTime) => _buildTaskCard(taskWithTime)),
      ],
    );
  }

  Widget _buildTaskCard(TaskWithTime taskWithTime) {
    final task = taskWithTime.task;
    final time = taskWithTime.scheduledTime;

    return AnimatedCard(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => TaskDetailsDialog(
            task: task,
            cachedPrayerTimes: _prayerTimes,
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditItemScreen(
                    task: task,
                    prayerTimes: _prayerTimes,
                  ),
                ),
              );
              if (result == true) {
                await _loadData();
              }
            },
            onDelete: () async {
              await TodoService.deleteTask(task.id);
              await _loadData();
            },
            onToggleComplete: () async {
              await TodoService.toggleTaskStatus(task);
              await _loadData();
            },
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppTheme.space16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: task.priority == TaskPriority.high
                ? AppThemeExtensions.errorGradient
                : task.priority == TaskPriority.medium
                    ? AppThemeExtensions.warningGradient
                    : AppThemeExtensions.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: _getPriorityColor(task.priority).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.task_alt,
            color: Colors.white,
          ),
        ),
        title: Text(
          task.title,
          style: AppTheme.titleMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              Icons.schedule,
              size: 14,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.space4),
            Text(
              DateFormat('h:mm a').format(time),
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space12,
            vertical: AppTheme.space6,
          ),
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(
              color: _getPriorityColor(task.priority).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            task.priority.name.toUpperCase(),
            style: AppTheme.labelSmall.copyWith(
              color: _getPriorityColor(task.priority),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppTheme.error;
      case TaskPriority.medium:
        return AppTheme.warning;
      case TaskPriority.low:
        return AppTheme.success;
    }
  }
}