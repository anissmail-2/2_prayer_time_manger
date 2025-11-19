import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable loading state widget
class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loading widget (shows content structure while loading)
class SkeletonLine extends StatefulWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const SkeletonLine({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<SkeletonLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(widget.borderRadius ?? 4),
            gradient: LinearGradient(
              begin: Alignment(-1.0 - 2 * _controller.value, 0.0),
              end: Alignment(1.0 - 2 * _controller.value, 0.0),
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Preset loading states for common scenarios
class LoadingStates {
  /// Loading prayer times
  static Widget loadingPrayerTimes(BuildContext context) {
    return const LoadingStateWidget(
      message: 'Loading prayer times...',
    );
  }

  /// Loading tasks
  static Widget loadingTasks(BuildContext context) {
    return const LoadingStateWidget(
      message: 'Loading your tasks...',
    );
  }

  /// Loading data
  static Widget loadingData(BuildContext context) {
    return const LoadingStateWidget(
      message: 'Loading...',
    );
  }

  /// Syncing data
  static Widget syncing(BuildContext context) {
    return const LoadingStateWidget(
      message: 'Syncing your data...',
    );
  }

  /// Generic loading (no message)
  static Widget loading(BuildContext context) {
    return const LoadingStateWidget();
  }

  /// Task card skeleton
  static Widget taskCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          SkeletonLine(width: 200, height: 20),
          SizedBox(height: 12),
          // Description skeleton
          SkeletonLine(width: 150, height: 14),
          SizedBox(height: 8),
          // Time skeleton
          SkeletonLine(width: 100, height: 14),
        ],
      ),
    );
  }

  /// Prayer time card skeleton
  static Widget prayerCardSkeleton() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          SkeletonLine(width: 150, height: 24),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 60, height: 16),
              SkeletonLine(width: 80, height: 16),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 60, height: 16),
              SkeletonLine(width: 80, height: 16),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLine(width: 60, height: 16),
              SkeletonLine(width: 80, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
