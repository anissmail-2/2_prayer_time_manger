import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/services/todo_service.dart';
import '../core/services/prayer_time_service.dart';
import '../core/services/user_preferences_service.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/helpers/logger.dart';
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
  bool _isPrayerModeEnabled = true;
  String? _errorMessage;

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
    try {
      final enabled = await UserPreferencesService.isPrayerModeEnabled();
      if (mounted) {
        setState(() {
          _isPrayerModeEnabled = enabled;
        });
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to load prayer mode', error: e, stackTrace: stackTrace, tag: 'Dashboard');
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isPrayerModeEnabled) {
        _prayerTimes = await PrayerTimeService.getPrayerTimes();
        _todayTasks = await TodoService.getUpcomingTasksWithTimes(_prayerTimes);
        _updateNextPrayer();
      } else {
        // In productivity mode, just load tasks without prayer times
        _todayTasks = await TodoService.getUpcomingTasksWithTimes({});
      }
      Logger.info('Dashboard data loaded successfully', tag: 'Dashboard');
    } catch (e, stackTrace) {
      Logger.error('Error loading dashboard data', error: e, stackTrace: stackTrace, tag: 'Dashboard');
      setState(() {
        _errorMessage = 'Failed to load data. Pull to refresh.';
      });
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

      if (mounted) {
        setState(() {
          _nextPrayer = nextPrayerName;
          _nextPrayerTime = _prayerTimes[nextPrayerName];
          _timeToNextPrayer = diff;
        });
      }
    }
  }

  bool _isTimeAfter(TimeOfDay time1, TimeOfDay time2) {
    if (time1.hour > time2.hour) return true;
    if (time1.hour == time2.hour && time1.minute > time2.minute) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppTheme.primary,
                  child: SafeArea(
                    bottom: false, // Don't apply safe area to bottom to handle FAB overlap
                    child: CustomScrollView(
                      slivers: [
                        // Header
                        SliverToBoxAdapter(
                          child: _isPrayerModeEnabled
                              ? ModernDashboardHeader(
                                  userName: 'User',
                                  greeting: _getGreeting(),
                                  nextPrayer: _nextPrayer,
                                  timeToNextPrayer: _timeToNextPrayer != null
                                      ? _formatTimeRemaining(_timeToNextPrayer!)
                                      : null,
                                )
                              : _buildProductivityHeader(),
                        ),

                        // Content with proper padding
                        SliverPadding(
                          padding: EdgeInsets.all(isSmallScreen ? AppTheme.space16 : AppTheme.space24),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Stats Cards - Responsive Layout
                              _buildResponsiveStats(isSmallScreen, isMediumScreen),

                              SizedBox(height: isSmallScreen ? AppTheme.space20 : AppTheme.space32),

                              // Today's Tasks Section
                              _buildTodayTasksSection(),

                              // Bottom padding to prevent FAB overlap
                              const SizedBox(height: 80),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
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
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Shimmer for header
            ShimmerCard(
              height: 200,
              width: double.infinity,
              borderRadius: 0,
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? AppTheme.space16 : AppTheme.space24),
              child: Column(
                children: [
                  // Shimmer for stats - responsive
                  if (isSmallScreen) ...[
                    ShimmerCard(height: 100, margin: const EdgeInsets.only(bottom: AppTheme.space12)),
                    ShimmerCard(height: 100, margin: const EdgeInsets.only(bottom: AppTheme.space12)),
                    ShimmerCard(height: 100),
                  ] else
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
                  ShimmerCard(height: 80, margin: const EdgeInsets.only(bottom: AppTheme.space12)),
                  ShimmerCard(height: 80, margin: const EdgeInsets.only(bottom: AppTheme.space12)),
                  ShimmerCard(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space24),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: AppTheme.space24),
              Text(
                'Oops! Something went wrong',
                style: AppTheme.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space12),
              Text(
                _errorMessage ?? 'Failed to load dashboard',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space32),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space32,
                    vertical: AppTheme.space16,
                  ),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductivityHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppThemeExtensions.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
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
              const SizedBox(height: AppTheme.space12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: AppTheme.space8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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

  Widget _buildResponsiveStats(bool isSmallScreen, bool isMediumScreen) {
    final completedToday = _todayTasks.where((t) => t.task.isCompletedForDate(DateTime.now())).length;
    final totalToday = _todayTasks.length;
    final pendingTasks = totalToday - completedToday;
    final progress = totalToday > 0 ? completedToday / totalToday : 0.0;

    // Small screens: Vertical stack
    if (isSmallScreen) {
      return Column(
        children: [
          _buildUniformStatCard(
            icon: Icons.check_circle_rounded,
            title: 'Completed Today',
            value: completedToday.toString(),
            subtitle: totalToday > 0 ? '${(progress * 100).toStringAsFixed(0)}% of tasks' : 'No tasks',
            color: AppTheme.success,
            gradient: AppThemeExtensions.successGradient,
          ),
          const SizedBox(height: AppTheme.space12),
          _buildUniformStatCard(
            icon: Icons.pending_actions_rounded,
            title: 'Pending Tasks',
            value: pendingTasks.toString(),
            subtitle: pendingTasks == 1 ? '1 task remaining' : '$pendingTasks tasks remaining',
            color: AppTheme.warning,
            gradient: AppThemeExtensions.warningGradient,
          ),
          const SizedBox(height: AppTheme.space12),
          _buildUniformStatCard(
            icon: Icons.track_changes_rounded,
            title: 'Daily Progress',
            value: '${(progress * 100).toInt()}%',
            subtitle: '$completedToday of $totalToday completed',
            color: AppTheme.primary,
            gradient: AppThemeExtensions.primaryGradient,
            showProgress: true,
            progress: progress,
          ),
        ],
      );
    }

    // Medium and large screens: Row layout
    return Row(
      children: [
        Expanded(
          child: _buildUniformStatCard(
            icon: Icons.check_circle_rounded,
            title: 'Completed',
            value: completedToday.toString(),
            subtitle: '${(progress * 100).toInt()}%',
            color: AppTheme.success,
            compact: true,
          ),
        ),
        const SizedBox(width: AppTheme.space12),
        Expanded(
          child: _buildUniformStatCard(
            icon: Icons.pending_actions_rounded,
            title: 'Pending',
            value: pendingTasks.toString(),
            subtitle: totalToday > 0 ? 'of $totalToday' : 'tasks',
            color: AppTheme.warning,
            compact: true,
          ),
        ),
        const SizedBox(width: AppTheme.space12),
        Expanded(
          child: _buildUniformStatCard(
            icon: Icons.track_changes_rounded,
            title: 'Progress',
            value: '${(progress * 100).toInt()}%',
            subtitle: 'complete',
            color: AppTheme.primary,
            compact: true,
            showProgress: true,
            progress: progress,
          ),
        ),
      ],
    );
  }

  Widget _buildUniformStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    Gradient? gradient,
    bool compact = false,
    bool showProgress = false,
    double progress = 0.0,
  }) {
    return AnimatedCard(
      padding: EdgeInsets.all(compact ? AppTheme.space16 : AppTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: compact ? 20 : 24,
                ),
              ),
              if (showProgress && compact)
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.1),
                    color: color,
                    strokeWidth: 3,
                  ),
                ),
            ],
          ),
          SizedBox(height: compact ? AppTheme.space12 : AppTheme.space16),
          Text(
            value,
            style: (compact ? AppTheme.headlineMedium : AppTheme.headlineLarge).copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space4),
            Text(
              subtitle,
              style: AppTheme.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
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
            if (upcomingTasks.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Navigate to agenda screen
                  // Will be handled by MainLayout navigation
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  textStyle: AppTheme.labelLarge,
                ),
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
          ...upcomingTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final taskWithTime = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: _buildTaskCard(taskWithTime),
            );
          }),
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
              Navigator.of(context).pop(); // Close dialog first
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
              Navigator.of(context).pop();
              await _loadData();
            },
            onToggleComplete: () async {
              await TodoService.toggleTaskStatus(task);
              Navigator.of(context).pop();
              await _loadData();
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space16),
        child: Row(
          children: [
            // Priority indicator with better visibility
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: _getPriorityColor(task.priority).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.task_alt,
                color: _getPriorityColor(task.priority),
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.space6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.space4),
                      Text(
                        DateFormat('h:mm a').format(time),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space8,
                          vertical: AppTheme.space4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
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
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.space8),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
              size: 20,
            ),
          ],
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
