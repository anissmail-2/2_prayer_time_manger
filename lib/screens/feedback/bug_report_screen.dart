import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/helpers/logger.dart';

/// Detailed bug report form for beta testers
class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _expectedController = TextEditingController();
  final _actualController = TextEditingController();

  bool _isSubmitting = false;
  String _severity = 'Medium';

  final List<String> _severityLevels = [
    'Low',
    'Medium',
    'High',
    'Critical',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _expectedController.dispose();
    _actualController.dispose();
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
          'brand': androidInfo.brand,
          'fingerprint': androidInfo.fingerprint,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
          'device': iosInfo.utsname.machine,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      }
    } catch (e) {
      Logger.error('Failed to collect device info', error: e, tag: 'BugReport');
    }

    return {'platform': Platform.operatingSystem};
  }

  Future<void> _submitBugReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final deviceInfo = await _collectDeviceInfo();
      deviceInfo['severity'] = _severity;

      final success = await FeedbackService.submitBugReport(
        email: _emailController.text.trim(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        stepsToReproduce: _stepsController.text.trim(),
        expectedBehavior: _expectedController.text.trim(),
        actualBehavior: _actualController.text.trim(),
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
                  child: Text('Bug report submitted! We\'ll investigate this.'),
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
            content: const Text('Failed to submit bug report. Please try again.'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      Logger.error('Submit bug report error', error: e, tag: 'BugReport');

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
        title: const Text('Report a Bug'),
        backgroundColor: AppTheme.error,
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
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      color: AppTheme.error,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help Us Fix This',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Detailed information helps us resolve bugs faster',
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
                  labelText: 'Your Email',
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

              // Bug title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Bug Title',
                  hintText: 'Brief description of the issue',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a bug title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Severity dropdown
              DropdownButtonFormField<String>(
                value: _severity,
                decoration: InputDecoration(
                  labelText: 'Severity',
                  prefixIcon: const Icon(Icons.priority_high),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _severityLevels.map((severity) {
                  return DropdownMenuItem(
                    value: severity,
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: _getSeverityColor(severity),
                        ),
                        const SizedBox(width: 8),
                        Text(severity),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _severity = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'What happened?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the bug';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Steps to reproduce
              TextFormField(
                controller: _stepsController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Steps to Reproduce',
                  hintText: '1. Go to...\n2. Click on...\n3. See error',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please list the steps to reproduce';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Expected behavior
              TextFormField(
                controller: _expectedController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Expected Behavior',
                  hintText: 'What should happen?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the expected behavior';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Actual behavior
              TextFormField(
                controller: _actualController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Actual Behavior',
                  hintText: 'What actually happened?',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the actual behavior';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBugReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
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
                        'Submit Bug Report',
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Device information (model, OS version, etc.) will be automatically included to help diagnose the issue.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.yellow.shade700;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
