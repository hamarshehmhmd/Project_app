import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';
import 'package:hape_vpn/presentation/providers/settings_provider.dart';
import 'package:hape_vpn/presentation/screens/settings/account_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/help_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/subscription_screen.dart';
import 'package:hape_vpn/presentation/screens/proxy/proxy_chain_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // User account section
          if (user != null) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountScreen(),
                  ),
                );
              },
            ),
            
            const Divider(),
          ],
          
          // Connection settings section
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'CONNECTION',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          // Auto-connect setting
          SwitchListTile(
            title: const Text('Auto-connect on Launch'),
            subtitle: const Text('Automatically connect to last server when app starts'),
            value: settingsState.autoConnect,
            onChanged: (value) {
              settingsNotifier.setAutoConnect(value);
            },
          ),
          
          // Kill switch setting
          SwitchListTile(
            title: const Text('Kill Switch'),
            subtitle: const Text('Block internet if VPN connection drops'),
            value: settingsState.killSwitch,
            onChanged: (value) {
              settingsNotifier.setKillSwitch(value);
            },
          ),
          
          // Protocol selection
          ListTile(
            title: const Text('VPN Protocol'),
            subtitle: Text(settingsState.protocol.name.toUpperCase()),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showProtocolSelectionDialog(context, ref);
            },
          ),
          
          // Proxy chains
          ListTile(
            title: const Text('Proxy Chains'),
            subtitle: const Text('Configure multi-hop proxy chains for enhanced privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProxyChainScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // App settings section
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'APP SETTINGS',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          // App theme
          ListTile(
            title: const Text('App Theme'),
            subtitle: Text(_getThemeName(settingsState.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemeSelectionDialog(context, ref);
            },
          ),
          
          // Start at login
          SwitchListTile(
            title: const Text('Start at System Login'),
            subtitle: const Text('Launch Hape VPN when your device starts'),
            value: settingsState.startAtLogin,
            onChanged: (value) {
              settingsNotifier.setStartAtLogin(value);
            },
          ),
          
          // Data collection
          SwitchListTile(
            title: const Text('Allow Anonymous Data Collection'),
            subtitle: const Text('Help us improve Hape VPN with anonymous usage data'),
            value: settingsState.allowDataCollection,
            onChanged: (value) {
              settingsNotifier.setAllowDataCollection(value);
            },
          ),
          
          const Divider(),
          
          // Subscription and Help section
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'SUBSCRIPTION & HELP',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          // Subscription
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('Subscription'),
            subtitle: Text(
              user?.isPremium == true ? 'Premium Plan' : 'Free Plan',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),
          
          // Help & support
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          
          // About
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Hape VPN',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset(
                  'assets/app_icon.png',
                  width: 48,
                  height: 48,
                ),
                applicationLegalese: '© 2023 Hape VPN. All rights reserved.',
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Hape VPN provides secure and private internet access with servers around the world.',
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutConfirmationDialog(context, ref);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Helper method to get user-friendly theme name
  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
  
  // Show theme selection dialog
  void _showThemeSelectionDialog(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentTheme = ref.read(settingsProvider).themeMode;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: currentTheme,
              onChanged: (value) {
                settingsNotifier.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: currentTheme,
              onChanged: (value) {
                settingsNotifier.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: currentTheme,
              onChanged: (value) {
                settingsNotifier.setThemeMode(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Show protocol selection dialog
  void _showProtocolSelectionDialog(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final currentProtocol = ref.read(settingsProvider).protocol;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose VPN Protocol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: VpnProtocol.values.map((protocol) {
            return RadioListTile<VpnProtocol>(
              title: Text(protocol.name.toUpperCase()),
              subtitle: Text(_getProtocolDescription(protocol)),
              value: protocol,
              groupValue: currentProtocol,
              onChanged: (value) {
                settingsNotifier.setProtocol(value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get protocol descriptions
  String _getProtocolDescription(VpnProtocol protocol) {
    switch (protocol) {
      case VpnProtocol.openvpn:
        return 'Better compatibility, slower';
      case VpnProtocol.wireguard:
        return 'Faster, more efficient, modern';
      case VpnProtocol.ikev2:
        return 'Good balance of speed and security';
    }
  }
  
  // Show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
} 