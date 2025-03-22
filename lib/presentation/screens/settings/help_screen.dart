import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Support options
          _buildSupportOption(
            context,
            icon: Icons.email,
            title: 'Contact Support',
            description: 'Send us an email with your question',
            onTap: () {
              // Open email client
            },
          ),
          
          _buildSupportOption(
            context,
            icon: Icons.chat,
            title: 'Live Chat',
            description: 'Chat with our support team (Premium only)',
            onTap: () {
              // Open live chat
            },
          ),
          
          const Divider(height: 32),
          
          // FAQs section
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFaqItem(
            context,
            question: 'What is a VPN?',
            answer: 'A Virtual Private Network (VPN) creates a secure, encrypted connection between your device and the internet. It routes your traffic through remote servers, protecting your data and hiding your IP address.',
          ),
          
          _buildFaqItem(
            context,
            question: 'Is Hape VPN secure?',
            answer: 'Yes, Hape VPN uses industry-standard encryption protocols to secure your data. We also maintain a strict no-logs policy, meaning we don\'t track or store your online activities.',
          ),
          
          _buildFaqItem(
            context,
            question: 'Why is my connection slow?',
            answer: 'VPN connection speeds can be affected by various factors including your base internet speed, distance to the VPN server, server load, and the VPN protocol used. Try connecting to a server closer to your location or switching protocols in the settings.',
          ),
          
          _buildFaqItem(
            context,
            question: 'What\'s the difference between free and premium?',
            answer: 'Free accounts have limited data usage, access to fewer servers, and may experience reduced speeds. Premium users enjoy unlimited data, access to all servers including specialized ones, higher speeds, and priority customer support.',
          ),
          
          _buildFaqItem(
            context,
            question: 'What is a proxy chain?',
            answer: 'A proxy chain routes your traffic through multiple servers in sequence, providing additional layers of privacy. While more secure, this may result in slower connection speeds compared to a single VPN connection.',
          ),
          
          _buildFaqItem(
            context,
            question: 'How do I cancel my subscription?',
            answer: 'You can cancel your subscription at any time through the Subscription section in Settings. If canceled, your premium features will remain active until the end of your current billing period.',
          ),
          
          const Divider(height: 32),
          
          // Troubleshooting section
          const Text(
            'Troubleshooting',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTroubleshootingItem(
            context,
            title: 'Connection Issues',
            steps: [
              'Check your internet connection',
              'Try a different server',
              'Switch VPN protocols in settings',
              'Restart the app',
              'Check if your firewall is blocking the connection'
            ],
          ),
          
          _buildTroubleshootingItem(
            context,
            title: 'Slow Connection',
            steps: [
              'Connect to a server closer to your location',
              'Try different VPN protocols in settings',
              'Avoid servers with high load percentages',
              'Check your base internet speed without VPN',
              'Premium servers typically offer better speeds'
            ],
          ),
          
          // Version information
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  'App Version: 1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2023 Hape VPN. All rights reserved.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildSupportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTroubleshootingItem(
    BuildContext context, {
    required String title,
    required List<String> steps,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(step)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
} 