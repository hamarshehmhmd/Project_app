import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/presentation/providers/proxy_provider.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';
import 'package:hape_vpn/presentation/screens/proxy/create_chain_screen.dart';

class ProxyScreen extends ConsumerStatefulWidget {
  const ProxyScreen({super.key});

  @override
  ConsumerState<ProxyScreen> createState() => _ProxyScreenState();
}

class _ProxyScreenState extends ConsumerState<ProxyScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load user's proxy chains
    Future.microtask(() async {
      await ref.read(proxyProvider.notifier).loadUserChains();
    });
  }

  @override
  Widget build(BuildContext context) {
    final proxyState = ref.watch(proxyProvider);
    final vpnState = ref.watch(vpnProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Chains'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateChainScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(proxyProvider.notifier).loadUserChains();
        },
        child: proxyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : proxyState.userChains.isEmpty
            ? _buildEmptyState()
            : _buildChainsList(proxyState.userChains, vpnState),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No proxy chains found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first proxy chain to route your traffic through multiple servers for enhanced privacy.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateChainScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create a Chain'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChainsList(List<ProxyChain> chains, VpnState vpnState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: chains.length,
      itemBuilder: (context, index) {
        final chain = chains[index];
        final isActive = vpnState.currentProxyChain?.id == chain.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          color: isActive 
              ? Theme.of(context).colorScheme.primaryContainer 
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        chain.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12.0),
                
                // Chain path visualization
                _buildChainPath(chain),
                
                const SizedBox(height: 16.0),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chain details
                    Text(
                      '${chain.servers.length} servers · ${_calculateLatency(chain)}ms latency',
                      style: TextStyle(
                        color: isActive
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : Colors.grey.shade600,
                      ),
                    ),
                    
                    // Action buttons
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to edit chain screen
                          },
                          tooltip: 'Edit',
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            if (isActive) {
                              ref.read(proxyProvider.notifier).disconnectChain();
                            } else {
                              ref.read(proxyProvider.notifier).connectChain(chain);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActive
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(isActive ? 'Disconnect' : 'Connect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildChainPath(ProxyChain chain) {
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          // Start node (your device)
          _buildChainNode(
            icon: Icons.smartphone,
            label: 'You',
            isFirst: true,
            isLast: false,
          ),
          
          // Server nodes
          for (int i = 0; i < chain.servers.length; i++) ...[
            Expanded(
              child: Container(
                height: 2,
                color: Colors.grey.shade400,
              ),
            ),
            _buildChainNode(
              icon: Icons.public,
              label: chain.servers[i].country.substring(0, 2).toUpperCase(),
              isFirst: false,
              isLast: i == chain.servers.length - 1,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildChainNode({
    required IconData icon,
    required String label,
    required bool isFirst,
    required bool isLast,
    Color? color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  // Calculate estimated latency for the proxy chain
  String _calculateLatency(ProxyChain chain) {
    // In a real app, this would be dynamically calculated or provided from backend
    int baseLatency = 30; // Base latency in ms
    
    // Each server adds latency
    int totalLatency = baseLatency + (chain.servers.length * 25);
    
    return totalLatency.toString();
  }
} 