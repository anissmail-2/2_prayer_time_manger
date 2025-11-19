import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/services/feedback_service.dart';
import '../screens/feedback/feedback_form_screen.dart';
import '../screens/feedback/bug_report_screen.dart';

/// Beta testing banner shown at the top of the app in debug/beta mode
class BetaBanner extends StatelessWidget {
  final Widget child;

  const BetaBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Only show in beta mode
    if (!FeedbackService.isBetaMode) {
      return child;
    }

    return Column(
      children: [
        _BetaBannerWidget(),
        Expanded(child: child),
      ],
    );
  }
}

class _BetaBannerWidget extends StatefulWidget {
  @override
  State<_BetaBannerWidget> createState() => _BetaBannerWidgetState();
}

class _BetaBannerWidgetState extends State<_BetaBannerWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warning.withOpacity(0.9),
            AppTheme.warning,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main banner
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.science,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'BETA VERSION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Expanded content
            if (_isExpanded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You\'re using a beta version of TaskFlow Pro. Your feedback helps us improve!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FeedbackFormScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.feedback,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Feedback',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BugReportScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.bug_report,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Report Bug',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
