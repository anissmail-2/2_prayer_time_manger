import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Reusable error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: AppTheme.error,
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),

            // Action button (if provided)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset error states for common scenarios
class ErrorStates {
  /// Network error
  static Widget networkError(BuildContext context, VoidCallback onRetry) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Check your internet connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Generic error with retry
  static Widget genericError(BuildContext context, VoidCallback onRetry,
      {String? errorMessage}) {
    return ErrorStateWidget(
      title: 'Oops! Something went wrong',
      message: errorMessage ??
          'An unexpected error occurred. Please try again.',
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }

  /// Permission denied
  static Widget permissionDenied(
      BuildContext context, String permissionName, VoidCallback onOpenSettings) {
    return ErrorStateWidget(
      icon: Icons.block,
      title: 'Permission Required',
      message:
          '$permissionName permission is required for this feature. Please grant it in Settings.',
      actionLabel: 'Open Settings',
      onAction: onOpenSettings,
    );
  }

  /// Location error
  static Widget locationError(BuildContext context, VoidCallback onRetry) {
    return ErrorStateWidget(
      icon: Icons.location_off,
      title: 'Location Not Available',
      message:
          'Unable to get your location. Please check your location settings.',
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }

  /// Data load failed
  static Widget dataLoadFailed(BuildContext context, VoidCallback onRetry) {
    return ErrorStateWidget(
      icon: Icons.cloud_off,
      title: 'Failed to Load Data',
      message: 'Unable to fetch your data. Please try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Feature unavailable
  static Widget featureUnavailable(BuildContext context, String featureName) {
    return ErrorStateWidget(
      icon: Icons.construction,
      title: '$featureName Unavailable',
      message: 'This feature is currently unavailable. Please try again later.',
    );
  }

  /// Timeout error
  static Widget timeout(BuildContext context, VoidCallback onRetry) {
    return ErrorStateWidget(
      icon: Icons.timer_off,
      title: 'Request Timed Out',
      message: 'The request took too long. Please try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
