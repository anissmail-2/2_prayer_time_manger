import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'location_permission_screen.dart';
import '../../core/services/onboarding_service.dart';
import '../main_layout.dart';

class OnboardingFeature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class ValuePropositionScreen extends StatefulWidget {
  const ValuePropositionScreen({super.key});

  @override
  State<ValuePropositionScreen> createState() => _ValuePropositionScreenState();
}

class _ValuePropositionScreenState extends State<ValuePropositionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingFeature> _features = const [
    OnboardingFeature(
      icon: Icons.mosque,
      title: 'Accurate Prayer Times',
      description: 'Get precise prayer times for 300+ cities worldwide',
      color: AppTheme.primary,
    ),
    OnboardingFeature(
      icon: Icons.schedule,
      title: 'Prayer-Aware Scheduling',
      description: 'Schedule tasks like "15 minutes before Dhuhr"',
      color: AppTheme.secondary,
    ),
    OnboardingFeature(
      icon: Icons.smart_toy,
      title: 'AI Assistant',
      description: 'Create tasks with natural language',
      color: AppTheme.success,
    ),
    OnboardingFeature(
      icon: Icons.offline_bolt,
      title: 'Works Offline',
      description: 'Full functionality without internet',
      color: AppTheme.info,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => _completeOnboarding(context),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Page view with features
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _buildFeaturePage(_features[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _features.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                  child: Text(
                    _currentPage == _features.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePage(OnboardingFeature feature) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feature.icon,
                    size: 60,
                    color: feature.color.withOpacity(value),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            feature.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            feature.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primary
            : AppTheme.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _onNext() {
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LocationPermissionScreen(),
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

  Future<void> _completeOnboarding(BuildContext context) async {
    await OnboardingService.setOnboardingComplete();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainLayout()),
        (route) => false,
      );
    }
  }
}
