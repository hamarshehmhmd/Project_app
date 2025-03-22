import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/presentation/providers/providers.dart';

class DataUsageCard extends ConsumerWidget {
  final int dataUsage;
  
  const DataUsageCard({
    super.key,
    required this.dataUsage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    // Convert bytes to MB/GB
    String formattedUsage = '';
    String formattedLimit = '';
    
    if (dataUsage < 1024 * 1024) {
      formattedUsage = '${(dataUsage / 1024).toStringAsFixed(2)} KB';
    } else if (dataUsage < 1024 * 1024 * 1024) {
      formattedUsage = '${(dataUsage / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      formattedUsage = '${(dataUsage / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    
    // Get the data limit from user profile
    final maxDataLimit = user?.maxDataLimit ?? 0;
    
    if (maxDataLimit < 1024 * 1024) {
      formattedLimit = '${(maxDataLimit / 1024).toStringAsFixed(2)} KB';
    } else if (maxDataLimit < 1024 * 1024 * 1024) {
      formattedLimit = '${(maxDataLimit / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      formattedLimit = '${(maxDataLimit / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
    
    // Calculate progress
    final progress = maxDataLimit > 0 
        ? (dataUsage / maxDataLimit).clamp(0.0, 1.0)
        : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Data Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$formattedUsage / $formattedLimit',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            
            const SizedBox(height: 8),
            
            // Show subscription status
            if (user != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscription: ${user.subscriptionTier.toUpperCase()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (user.subscriptionTier == 'free')
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to upgrade screen
                      },
                      icon: const Icon(Icons.star),
                      label: const Text('Upgrade'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
} 