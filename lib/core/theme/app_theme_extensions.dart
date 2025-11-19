import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Extended theme utilities for modern, engaging UI
class AppThemeExtensions {
  AppThemeExtensions._();

  // ==================== Gradients ====================

  /// Primary gradient (Blue to Purple)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (Green shades)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning gradient (Orange/Yellow)
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft gradient background
  static const LinearGradient softBackgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Prayer time gradient
  static const LinearGradient prayerGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Sunset gradient
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEC4899), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Glass Morphism ====================

  /// Glass container decoration with blur effect
  static BoxDecoration glassDecoration({
    Color? color,
    double? radius,
    bool hasBorder = true,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.7),
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMedium),
      border: hasBorder
          ? Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  /// Frosted glass effect
  static BoxDecoration frostedGlassDecoration({
    double? radius,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMedium),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // ==================== Card Variations ====================

  /// Elevated card with gradient shadow
  static BoxDecoration elevatedCardDecoration({
    Color? color,
    Gradient? gradient,
    double? radius,
  }) {
    return BoxDecoration(
      color: gradient == null ? (color ?? Colors.white) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusLarge),
      boxShadow: [
        BoxShadow(
          color: (gradient != null ? AppTheme.primary : Colors.black)
              .withOpacity(0.08),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        BoxShadow(
          color: (gradient != null ? AppTheme.primary : Colors.black)
              .withOpacity(0.04),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Neumorphic card (soft shadow)
  static BoxDecoration neumorphicDecoration({
    Color? color,
    double? radius,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: color ?? AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMedium),
      boxShadow: isPressed
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
                inset: true,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.white,
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(5, 5),
              ),
            ],
    );
  }

  // ==================== Animated Containers ====================

  /// Shimmer loading effect colors
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, 0.0),
    end: Alignment(1.0, 0.0),
  );

  /// Pulse animation decoration
  static BoxDecoration pulseDecoration({
    Color? color,
    double? radius,
  }) {
    return BoxDecoration(
      color: (color ?? AppTheme.primary).withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMedium),
      border: Border.all(
        color: (color ?? AppTheme.primary).withOpacity(0.3),
        width: 2,
      ),
    );
  }

  // ==================== Icon Backgrounds ====================

  /// Gradient icon background
  static BoxDecoration iconGradientBackground({
    Gradient? gradient,
    double size = 48,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Soft icon background
  static BoxDecoration softIconBackground({
    Color? color,
    double? radius,
  }) {
    return BoxDecoration(
      color: (color ?? AppTheme.primary).withOpacity(0.1),
      borderRadius: BorderRadius.circular(radius ?? AppTheme.radiusMedium),
    );
  }

  // ==================== Floating Action Button ====================

  /// Modern FAB with gradient
  static BoxDecoration fabDecoration({
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient ?? primaryGradient,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // ==================== Status Indicators ====================

  /// Success badge decoration
  static BoxDecoration successBadge() {
    return BoxDecoration(
      gradient: successGradient,
      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      boxShadow: [
        BoxShadow(
          color: AppTheme.success.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Warning badge decoration
  static BoxDecoration warningBadge() {
    return BoxDecoration(
      gradient: warningGradient,
      borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
      boxShadow: [
        BoxShadow(
          color: AppTheme.warning.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ==================== Bottom Sheet ====================

  /// Modern bottom sheet decoration
  static BoxDecoration bottomSheetDecoration() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusXLarge),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 20,
          offset: Offset(0, -5),
        ),
      ],
    );
  }

  // ==================== Dividers ====================

  /// Gradient divider
  static Widget gradientDivider({
    double height = 1,
    Gradient? gradient,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? primaryGradient,
      ),
    );
  }

  // ==================== Animations ====================

  /// Scale transition animation
  static Animation<double> scaleAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// Slide up animation
  static Animation<Offset> slideUpAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// Fade animation
  static Animation<double> fadeAnimation(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ),
    );
  }
}
