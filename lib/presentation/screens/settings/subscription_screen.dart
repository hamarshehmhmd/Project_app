import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in'),
        ),
      );
    }
    
    final isPremium = user.isPremium;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current plan card
              _buildCurrentPlanCard(context, user),
              
              const SizedBox(height: 24),
              
              // Premium benefits
              const Text(
                'Premium Benefits',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Benefits list
              _buildBenefitItem(
                icon: Icons.speed,
                title: 'Faster Speeds',
                description: 'Get priority bandwidth for lightning-fast connections',
              ),
              _buildBenefitItem(
                icon: Icons.public,
                title: 'All Servers',
                description: 'Access to 500+ premium servers in 60+ countries',
              ),
              _buildBenefitItem(
                icon: Icons.data_usage,
                title: 'Unlimited Data',
                description: 'No data caps or restrictions',
              ),
              _buildBenefitItem(
                icon: Icons.devices,
                title: 'Multiple Devices',
                description: 'Connect up to 5 devices simultaneously',
              ),
              _buildBenefitItem(
                icon: Icons.support_agent,
                title: 'Priority Support',
                description: '24/7 priority customer support',
              ),
              _buildBenefitItem(
                icon: Icons.route,
                title: 'Advanced Proxy Chains',
                description: 'Create unlimited multi-hop proxy chains for enhanced privacy',
              ),
              
              const SizedBox(height: 24),
              
              // Subscription plans
              const Text(
                'Subscription Plans',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Plan options
              _buildPlanOptions(context, isPremium),
              
              const SizedBox(height: 24),
              
              // Disclaimer
              Text(
                'All plans include our full suite of premium features. Subscriptions will automatically renew unless canceled at least 24 hours before the end of the current period. You can manage your subscriptions in your account settings.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentPlanCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final isPremium = user.isPremium;
    
    return Card(
      color: isPremium ? theme.colorScheme.primary : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPremium ? Icons.workspace_premium : Icons.account_circle,
                  size: 24,
                  color: isPremium
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  isPremium ? 'Premium Plan' : 'Free Plan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: isPremium
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isPremium && user.subscriptionEndDate != null) ...[
              Text(
                'Your subscription renews on',
                style: TextStyle(
                  color: isPremium
                      ? theme.colorScheme.onPrimary.withOpacity(0.8)
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(user.subscriptionEndDate!),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isPremium
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to billing history
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isPremium
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      side: BorderSide(
                        color: isPremium
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    child: const Text('Billing History'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showCancelConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPremium
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      foregroundColor: isPremium
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onPrimary,
                    ),
                    child: const Text('Cancel Subscription'),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'You are currently on the free plan with limited features.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Scroll to plans section
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanOptions(BuildContext context, bool isPremium) {
    return Column(
      children: [
        // Monthly Plan
        _buildPlanCard(
          context,
          title: 'Monthly',
          price: '\$9.99',
          period: 'per month',
          features: [
            'Billed monthly',
            'Cancel anytime',
            'All premium features',
          ],
          isRecommended: false,
          onTap: () => _handleSubscribe('monthly'),
          isPremium: isPremium,
        ),
        
        const SizedBox(height: 16),
        
        // Annual Plan (recommended)
        _buildPlanCard(
          context,
          title: 'Annual',
          price: '\$59.99',
          period: 'per year',
          discount: '50% off',
          features: [
            'Billed annually',
            'Save \$59.89 per year',
            'All premium features',
          ],
          isRecommended: true,
          onTap: () => _handleSubscribe('annual'),
          isPremium: isPremium,
        ),
        
        const SizedBox(height: 16),
        
        // Lifetime Plan
        _buildPlanCard(
          context,
          title: 'Lifetime',
          price: '\$199.99',
          period: 'one-time payment',
          features: [
            'Pay once, use forever',
            'No recurring payments',
            'All premium features and updates',
          ],
          isRecommended: false,
          onTap: () => _handleSubscribe('lifetime'),
          isPremium: isPremium,
        ),
      ],
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? discount,
    required List<String> features,
    required bool isRecommended,
    required VoidCallback onTap,
    required bool isPremium,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        children: [
          if (isRecommended) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Text(
                'BEST VALUE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (discount != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      discount,
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(feature),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isPremium ? null : onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRecommended
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      foregroundColor: isRecommended
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    child: Text(isPremium ? 'Current Plan' : 'Select Plan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Format date to readable format
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  // Handle subscription purchase
  void _handleSubscribe(String plan) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // In a real app, this would initiate a purchase
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Show cancel confirmation dialog
  void _showCancelConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your premium subscription? You will continue to have access to premium features until the end of your current billing cycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () {
              // In a real app, this would cancel the subscription
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Subscription canceled successfully'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }
} 