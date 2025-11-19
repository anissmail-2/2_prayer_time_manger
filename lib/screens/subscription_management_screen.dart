import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/helpers/logger.dart';
import '../core/helpers/analytics_helper.dart';
import '../core/theme/app_theme.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  bool _isLoading = true;
  String _currentTier = 'free';
  DateTime? _expirationDate;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'Free',
      price: '\$0',
      period: 'forever',
      features: [
        'Unlimited tasks and spaces',
        'Prayer time integration',
        'Basic AI assistance',
        'Local data storage',
        'Task reminders',
      ],
      isPopular: false,
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'Pro',
      price: '\$4.99',
      period: 'per month',
      features: [
        'Everything in Free',
        'Advanced AI features',
        'Cloud sync across devices',
        'Priority support',
        'Custom themes',
        'Advanced analytics',
        'Unlimited voice input',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'Premium',
      price: '\$9.99',
      period: 'per month',
      features: [
        'Everything in Pro',
        'Team collaboration',
        'Custom integrations',
        'Dedicated support',
        'Early access to features',
        'No ads (forever)',
      ],
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsHelper.logScreenView('subscription_management');
    _loadSubscriptionInfo();
  }

  Future<void> _loadSubscriptionInfo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get subscription tier from AuthService
      _currentTier = await AuthService.getSubscriptionTier();

      // TODO: Load expiration date from backend
      // For now, set a placeholder
      if (_currentTier != 'free') {
        _expirationDate = DateTime.now().add(const Duration(days: 30));
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to load subscription info',
        error: e,
        stackTrace: stackTrace,
        tag: 'Subscription',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleSubscribe(String planId) {
    // TODO: Implement payment/subscription flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription'),
        content: Text(
          'Subscription management will be available in a future update.\n\n'
          'You selected: ${_plans.firstWhere((p) => p.id == planId).name} Plan',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    AnalyticsHelper.logEvent(name: 'subscription_initiated', parameters: {'plan': planId});
  }

  Widget _buildCurrentPlanCard() {
    final currentPlan = _plans.firstWhere(
      (p) => p.id == _currentTier,
      orElse: () => _plans.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Plan',
                style: AppTheme.labelMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  'Active',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentPlan.name,
            style: AppTheme.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentPlan.price,
            style: AppTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_expirationDate != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(width: 8),
                Text(
                  'Renews on ${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isCurrentPlan = plan.id == _currentTier;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: plan.isPopular
              ? AppTheme.primary
              : AppTheme.borderLight,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  'MOST POPULAR',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: AppTheme.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.price,
                      style: AppTheme.headlineLarge.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        plan.period,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.success,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan ? null : () => _handleSubscribe(plan.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? AppTheme.borderLight
                          : (plan.isPopular ? AppTheme.primary : AppTheme.secondary),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan ? 'Current Plan' : 'Subscribe',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Subscription',
          style: AppTheme.headlineMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current Plan Card
                _buildCurrentPlanCard(),
                const SizedBox(height: 32),

                // Available Plans
                Text(
                  'Available Plans',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Plan Cards
                ..._plans.map((plan) => _buildPlanCard(plan)),

                // Footer Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    'Note: Subscription features are in development. '
                    'Currently all features are available for free during beta.',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.info,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    required this.isPopular,
  });
}
