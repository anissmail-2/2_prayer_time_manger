import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_extensions.dart';

/// Animated card that scales on tap with beautiful shadows
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Gradient? gradient;
  final Color? color;
  final double? borderRadius;
  final bool elevated;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.color,
    this.borderRadius,
    this.elevated = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: widget.elevated
              ? AppThemeExtensions.elevatedCardDecoration(
                  color: widget.color,
                  gradient: widget.gradient,
                  radius: widget.borderRadius,
                )
              : AppTheme.cardDecoration(
                  color: widget.color,
                  radius: widget.borderRadius,
                ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Glass morphism card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(AppTheme.space16),
        decoration: AppThemeExtensions.glassDecoration(
          radius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

/// Gradient card with animated border
class GradientCard extends StatefulWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
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
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppTheme.radiusLarge,
              ),
              gradient: widget.gradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3 * _controller.value),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(AppTheme.space20),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading card
class ShimmerCard extends StatefulWidget {
  final double height;
  final double? width;
  final double? borderRadius;
  final EdgeInsets? margin;

  const ShimmerCard({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
    this.margin,
  });

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
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
          height: widget.height,
          width: widget.width,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppTheme.radiusMedium,
            ),
            gradient: LinearGradient(
              begin: Alignment(_controller.value * 2 - 1, 0),
              end: Alignment(_controller.value * 2, 0),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pulse animation card for notifications
class PulseCard extends StatefulWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;

  const PulseCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  State<PulseCard> createState() => _PulseCardState();
}

class _PulseCardState extends State<PulseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
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
        return Opacity(
          opacity: _animation.value,
          child: Container(
            margin: widget.margin,
            padding: widget.padding ?? const EdgeInsets.all(AppTheme.space16),
            decoration: AppThemeExtensions.pulseDecoration(
              color: widget.color,
              radius: widget.borderRadius,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
