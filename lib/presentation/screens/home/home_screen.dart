import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';
import 'package:hape_vpn/presentation/providers/server_provider.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';
import 'package:hape_vpn/presentation/screens/proxy/proxy_screen.dart';
import 'package:hape_vpn/presentation/screens/servers/server_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/settings_screen.dart';
import 'package:hape_vpn/presentation/widgets/connection_button.dart';
import 'package:hape_vpn/presentation/widgets/data_usage_card.dart';
import 'package:hape_vpn/presentation/widgets/server_list.dart';
import 'package:hape_vpn/presentation/widgets/status_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize data when screen loads
    Future.microtask(() async {
      // Load recommended servers and user's chains
      await ref.read(serverProvider.notifier).loadRecommendedServers();
      await ref.read(serverProvider.notifier).loadUserChains();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Get current auth state
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hape VPN'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const ServerScreen(),
          const ProxyScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.public),
            label: 'Servers',
          ),
          NavigationDestination(
            icon: Icon(Icons.route),
            label: 'Proxy Chains',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
  
  Widget _buildHomeContent() {
    // Watch required providers
    final vpnState = ref.watch(vpnProvider);
    final serverState = ref.watch(serverProvider);
    final authState = ref.watch(authProvider);
    
    // Calculate data usage (this would normally come from the VPN provider)
    final dataUsage = vpnState.dataUsage;
    
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh all data
        await ref.read(vpnProvider.notifier).refreshVpnStatus();
        await ref.read(serverProvider.notifier).loadRecommendedServers();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status card showing connection status
            const StatusCard(),
            
            // Connection button
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: ConnectionButton(),
              ),
            ),
            
            // Data usage card
            DataUsageCard(dataUsage: dataUsage),
            
            const SizedBox(height: 16),
            
            // Recommended servers section
            if (serverState.recommendedServers.isNotEmpty) ...[
              ServerList(
                servers: serverState.recommendedServers,
                title: 'Recommended Servers',
                showTitle: true,
                maxItems: 3,
              ),
              
              // View all servers button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1; // Switch to Servers tab
                    });
                  },
                  child: const Text('View All Servers'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 