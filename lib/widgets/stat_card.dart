import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';
import 'animated_card.dart';

/// Modern stat card with icon and animated numbers
class StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Gradient? gradient;
  final Color? iconColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.gradient,
    this.iconColor,
    this.onTap,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: widget.onTap,
      gradient: widget.gradient,
      padding: const EdgeInsets.all(AppTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Animated Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.space12),
                    decoration: AppThemeExtensions.softIconBackground(
                      color: widget.iconColor ?? AppTheme.primary,
                      radius: AppTheme.radiusMedium,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor ?? AppTheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              // Optional trend indicator
              if (widget.subtitle != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space8,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    widget.subtitle!,
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          // Value
          FadeTransition(
            opacity: _scaleAnimation,
            child: Text(
              widget.value,
              style: AppTheme.headlineLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.gradient != null
                    ? Colors.white
                    : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          // Title
          FadeTransition(
            opacity: _scaleAnimation,
            child: Text(
              widget.title,
              style: AppTheme.bodyMedium.copyWith(
                color: widget.gradient != null
                    ? Colors.white.withOpacity(0.8)
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stat card for grid layouts
class CompactStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final VoidCallback? onTap;

  const CompactStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: AppThemeExtensions.softIconBackground(
              color: color ?? AppTheme.primary,
              radius: AppTheme.radiusLarge,
            ),
            child: Icon(
              icon,
              color: color ?? AppTheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          Text(
            value,
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Progress stat card with circular indicator
class ProgressStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final double progress; // 0.0 to 1.0
  final String valueText;
  final Color? color;
  final VoidCallback? onTap;

  const ProgressStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.progress,
    required this.valueText,
    this.color,
    this.onTap,
  });

  @override
  State<ProgressStatCard> createState() => _ProgressStatCardState();
}

class _ProgressStatCardState extends State<ProgressStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primary;

    return AnimatedCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(AppTheme.space20),
      child: Row(
        children: [
          // Circular progress
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: color.withOpacity(0.1),
                      color: color,
                      strokeWidth: 6,
                    ),
                    Center(
                      child: Icon(
                        widget.icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: AppTheme.space16),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  widget.valueText,
                  style: AppTheme.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}% Complete',
                      style: AppTheme.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trending stat card with sparkline
class TrendingStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String trend;
  final bool isTrendingUp;
  final Color? color;
  final VoidCallback? onTap;

  const TrendingStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.isTrendingUp,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isTrendingUp ? AppTheme.success : AppTheme.error;
    final trendIcon = isTrendingUp ? Icons.trending_up : Icons.trending_down;

    return AnimatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.space12),
                decoration: AppThemeExtensions.softIconBackground(
                  color: color ?? AppTheme.primary,
                  radius: AppTheme.radiusMedium,
                ),
                child: Icon(
                  icon,
                  color: color ?? AppTheme.primary,
                  size: 20,
                ),
              ),
              Row(
                children: [
                  Icon(
                    trendIcon,
                    size: 16,
                    color: trendColor,
                  ),
                  const SizedBox(width: AppTheme.space4),
                  Text(
                    trend,
                    style: AppTheme.labelMedium.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space16),
          Text(
            value,
            style: AppTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
