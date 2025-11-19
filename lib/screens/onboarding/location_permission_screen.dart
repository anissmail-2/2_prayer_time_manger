import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/permission_helper.dart';
import '../../core/services/location_service.dart';
import '../../core/helpers/logger.dart';
import 'notification_permission_screen.dart';
import 'manual_location_screen.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

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

              // Location icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 60,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Enable Location',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We need your location to provide accurate prayer times for your city.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock,
                      color: AppTheme.success,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your location is never shared or stored on our servers.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Enable location button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _requestLocation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: const Text(
                    'Enable Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Manual setup button
              TextButton(
                onPressed: () => _setManually(context),
                child: Text(
                  'Set Location Manually',
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

  Future<void> _requestLocation(BuildContext context) async {
    try {
      // Request location permission
      final hasPermission = await PermissionHelper.requestLocationPermission();

      if (!context.mounted) return;

      if (hasPermission) {
        // Try to get current location
        try {
          final location = await LocationService.getCurrentLocation();
          Logger.success(
            'Location obtained: ${location?.city ?? "Unknown"}',
            tag: 'LocationPermission',
          );

          if (context.mounted) {
            // Proceed to next screen
            _proceedToNext(context);
          }
        } catch (e) {
          Logger.error(
            'Failed to get location',
            error: e,
            tag: 'LocationPermission',
          );

          if (context.mounted) {
            // If location fetch failed, let user set manually
            _setManually(context);
          }
        }
      } else {
        // Permission denied, show manual option
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Location permission is required for accurate prayer times',
              ),
              action: SnackBarAction(
                label: 'Set Manually',
                onPressed: () => _setManually(context),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      Logger.error(
        'Error requesting location permission',
        error: e,
        stackTrace: stackTrace,
        tag: 'LocationPermission',
      );

      if (context.mounted) {
        _setManually(context);
      }
    }
  }

  void _setManually(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ManualLocationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _proceedToNext(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NotificationPermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
