import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/permission_helper.dart';
import '../../core/helpers/logger.dart';
import '../../core/services/onboarding_service.dart';
import '../main_layout.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Notification icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  size: 60,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Enable Notifications',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Get reminders for your tasks and upcoming prayers.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Info note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You can customize or disable them anytime in settings.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.info,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Enable notifications button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _requestNotifications(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Skip button
              TextButton(
                onPressed: () => _skipNotifications(context),
                child: Text(
                  'Skip for Now',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestNotifications(BuildContext context) async {
    try {
      final hasPermission =
          await PermissionHelper.requestNotificationPermission();

      Logger.info(
        'Notification permission: ${hasPermission ? "granted" : "denied"}',
        tag: 'NotificationPermission',
      );

      if (context.mounted) {
        if (hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications enabled successfully!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Proceed regardless of permission result
        _completeOnboarding(context);
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error requesting notification permission',
        error: e,
        stackTrace: stackTrace,
        tag: 'NotificationPermission',
      );

      if (context.mounted) {
        _completeOnboarding(context);
      }
    }
  }

  void _skipNotifications(BuildContext context) {
    Logger.info('Notifications skipped during onboarding',
        tag: 'NotificationPermission');
    _completeOnboarding(context);
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    // Mark onboarding as complete
    await OnboardingService.setOnboardingComplete();

    if (context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.celebration, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Welcome to TaskFlow Pro! 🎉')),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    }
  }
}
