import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';

/// Beautiful empty state widget with icon and action button
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.illustration,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space32),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon or Illustration
                if (widget.illustration != null)
                  widget.illustration!
                else
                  Container(
                    width: 120,
                    height: 120,
                    decoration: AppThemeExtensions.iconGradientBackground(
                      gradient: AppThemeExtensions.primaryGradient,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: AppTheme.space32),
                // Title
                Text(
                  widget.title,
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.space12),
                // Message
                Text(
                  widget.message,
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: AppTheme.space32),
                  // Action Button
                  ElevatedButton.icon(
                    onPressed: widget.onAction,
                    icon: const Icon(Icons.add),
                    label: Text(widget.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space32,
                        vertical: AppTheme.space16,
                      ),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact empty state for smaller areas
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          Text(
            message,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppTheme.space16),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated floating icons for decorative empty states
class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final Duration duration;
  final double offset;

  const FloatingIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.duration = const Duration(seconds: 3),
    this.offset = 20,
  });

  @override
  State<FloatingIcon> createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: widget.offset).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color.withOpacity(0.3),
          ),
        );
      },
    );
  }
}
