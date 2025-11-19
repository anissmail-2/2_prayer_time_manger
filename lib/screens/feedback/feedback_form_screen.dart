import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/logger.dart';

/// In-app feedback form for beta testers
class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _feedbackType = 'General';
  bool _isSubmitting = false;

  final List<String> _feedbackTypes = [
    'General',
    'Bug Report',
    'Feature Request',
    'UI/UX Feedback',
    'Performance Issue',
    'Other',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'version': androidInfo.version.release,
          'sdk': androidInfo.version.sdkInt,
          'device': androidInfo.device,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
          'device': iosInfo.utsname.machine,
        };
      }
    } catch (e) {
      Logger.error('Failed to collect device info', error: e, tag: 'FeedbackForm');
    }

    return {'platform': Platform.operatingSystem};
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final deviceInfo = await _collectDeviceInfo();

      final success = await FeedbackService.submitFeedback(
        email: _emailController.text.trim(),
        feedbackType: _feedbackType,
        message: _messageController.text.trim(),
        deviceInfo: deviceInfo,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Thank you! Your feedback has been submitted.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to submit feedback. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      Logger.error('Submit feedback error', error: e, tag: 'FeedbackForm');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.feedback,
                      color: AppTheme.primary,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We value your feedback!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Help us improve TaskFlow Pro',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'your.email@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Feedback type dropdown
              DropdownButtonFormField<String>(
                value: _feedbackType,
                decoration: InputDecoration(
                  labelText: 'Feedback Type',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _feedbackTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _feedbackType = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Message field
              TextFormField(
                controller: _messageController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Your Feedback',
                  hintText: 'Tell us what you think...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback helps us improve. Device information is collected automatically for debugging purposes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
