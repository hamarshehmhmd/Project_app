import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/proxy_server.dart';
import 'package:hape_vpn/presentation/providers/proxy_provider.dart';

class ProxyChainScreen extends ConsumerStatefulWidget {
  const ProxyChainScreen({super.key});

  @override
  ConsumerState<ProxyChainScreen> createState() => _ProxyChainScreenState();
}

class _ProxyChainScreenState extends ConsumerState<ProxyChainScreen> {
  final TextEditingController _chainNameController = TextEditingController();
  List<ProxyServer> _selectedProxies = [];
  bool _isCreatingNewChain = false;
  
  @override
  void dispose() {
    _chainNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proxyState = ref.watch(proxyProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Chains'),
      ),
      body: proxyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Current proxy status
                _buildProxyStatus(proxyState),
                
                // Available chains
                Expanded(
                  child: proxyState.chains.isEmpty
                      ? _buildEmptyState()
                      : _buildChainsList(proxyState),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isCreatingNewChain = true;
            _selectedProxies = [];
            _chainNameController.clear();
          });
          _showCreateChainDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildProxyStatus(ProxyState state) {
    final theme = Theme.of(context);
    final isActive = state.status == ProxyStatus.active;
    
    return Card(
      margin: const EdgeInsets.all(16),
      color: isActive ? theme.colorScheme.primary : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Proxy Status: ${isActive ? 'Active' : 'Inactive'}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isActive 
                        ? theme.colorScheme.onPrimary 
                        : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isActive && state.activeChain != null) ...[
              Text(
                'Active Chain: ${state.activeChain!.chainName}',
                style: TextStyle(
                  color: isActive 
                      ? theme.colorScheme.onPrimary 
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Proxy Count: ${state.activeChain!.items.length}',
                style: TextStyle(
                  color: isActive 
                      ? theme.colorScheme.onPrimary 
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(proxyProvider.notifier).deactivateProxyChain();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.primary,
                    foregroundColor: isActive 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Deactivate Proxy Chain'),
                ),
              ),
            ] else ...[
              Text(
                'No active proxy chain',
                style: TextStyle(
                  color: isActive 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
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
            'No Proxy Chains Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first proxy chain to enhance your privacy',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isCreatingNewChain = true;
                    _selectedProxies = [];
                    _chainNameController.clear();
                  });
                  _showCreateChainDialog();
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Manually'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _createRecommendedChain,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Auto Create'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildChainsList(ProxyState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.chains.length,
      itemBuilder: (context, index) {
        final chain = state.chains[index];
        final isActive = state.activeChain?.id == chain.id;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.route,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chain.chainName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Proxy Servers: ${chain.items.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Created: ${_formatDate(chain.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showChainDetails(chain),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isActive
                            ? null
                            : () {
                                ref.read(proxyProvider.notifier).activateProxyChain(chain);
                              },
                        child: Text(isActive ? 'Active' : 'Activate'),
                      ),
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
  
  void _showCreateChainDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Proxy Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _chainNameController,
              decoration: const InputDecoration(
                labelText: 'Chain Name',
                hintText: 'Enter a name for your proxy chain',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showProxySelectionScreen();
              },
              child: const Text('Select Proxies'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isCreatingNewChain = false;
              });
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _selectedProxies.isEmpty || _chainNameController.text.isEmpty
                ? null
                : () {
                    _createProxyChain();
                    Navigator.pop(context);
                  },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  void _showProxySelectionScreen() async {
    final proxyState = ref.read(proxyProvider);
    
    if (proxyState.availableProxies.isEmpty) {
      // Fetch proxies if none are available
      await ref.read(proxyProvider.notifier).fetchPublicProxies();
    }
    
    if (!mounted) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProxySelectionScreen(
          availableProxies: ref.read(proxyProvider).availableProxies,
          selectedProxies: _selectedProxies,
        ),
      ),
    );
    
    if (result != null && result is List<ProxyServer>) {
      setState(() {
        _selectedProxies = result;
      });
    }
  }
  
  void _createProxyChain() {
    if (_selectedProxies.isEmpty || _chainNameController.text.isEmpty) {
      return;
    }
    
    final chain = ProxyChain(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: ref.read(proxyProvider).userId ?? 'guest',
      chainName: _chainNameController.text,
      createdAt: DateTime.now(),
      items: _selectedProxies.asMap().entries.map((entry) {
        return ProxyChainItem(
          id: 'item-${entry.key}',
          chainId: DateTime.now().millisecondsSinceEpoch.toString(),
          proxyId: entry.value.id,
          sequenceOrder: entry.key,
          proxyServer: entry.value,
        );
      }).toList(),
    );
    
    ref.read(proxyProvider.notifier).createProxyChain(chain);
    
    setState(() {
      _isCreatingNewChain = false;
      _selectedProxies = [];
      _chainNameController.clear();
    });
  }
  
  void _createRecommendedChain() async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Creating Recommended Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Finding optimal proxy servers...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a moment as we test the best proxies available.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
    try {
      // Create a recommended chain
      final chain = await ref.read(proxyProvider.notifier).createRecommendedChain();
      
      if (!mounted) return;
      Navigator.pop(context); // Dismiss the loading dialog
      
      if (chain != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created optimized chain "${chain.chainName}" with ${chain.items.length} proxies'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create a recommended chain. Try again or create one manually.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dismiss the loading dialog
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showChainDetails(ProxyChain chain) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chain.chainName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Created: ${_formatDate(chain.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Divider(),
            const Text(
              'Proxy Servers:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: chain.items.length,
                itemBuilder: (context, index) {
                  final item = chain.items[index];
                  final proxy = item.proxyServer;
                  
                  if (proxy == null) {
                    return const ListTile(
                      title: Text('Unknown Proxy'),
                      subtitle: Text('Proxy details not available'),
                    );
                  }
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(proxy.proxyName),
                    subtitle: Text('${proxy.ipAddress}:${proxy.port}'),
                    trailing: Icon(
                      Icons.arrow_downward,
                      color: index < chain.items.length - 1 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.transparent,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showTestChainDialog(chain);
                  },
                  icon: const Icon(Icons.speed),
                  label: const Text('Test Speed'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteChainDialog(chain);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showTestChainDialog(ProxyChain chain) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Testing Proxy Chain'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Testing connection speed...'),
          ],
        ),
      ),
    );
    
    final speed = await ref.read(proxyProvider.notifier).testProxyChainSpeed(chain);
    
    if (!mounted) return;
    
    Navigator.pop(context); // Close the progress dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              speed > 200 ? Icons.warning : Icons.check_circle,
              color: speed > 200 
                  ? Theme.of(context).colorScheme.error 
                  : Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Latency: $speed ms',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              speed > 200 
                  ? 'High latency detected. This chain may be slow.'
                  : 'Good latency. This chain should perform well.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteChainDialog(ProxyChain chain) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Proxy Chain'),
        content: Text(
          'Are you sure you want to delete the chain "${chain.chainName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(proxyProvider.notifier).deleteProxyChain(chain.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Screen for selecting proxies
class ProxySelectionScreen extends StatefulWidget {
  final List<ProxyServer> availableProxies;
  final List<ProxyServer> selectedProxies;
  
  const ProxySelectionScreen({
    super.key,
    required this.availableProxies,
    required this.selectedProxies,
  });

  @override
  State<ProxySelectionScreen> createState() => _ProxySelectionScreenState();
}

class _ProxySelectionScreenState extends State<ProxySelectionScreen> {
  late List<ProxyServer> _availableProxies;
  late List<ProxyServer> _selectedProxies;
  
  @override
  void initState() {
    super.initState();
    _availableProxies = widget.availableProxies;
    _selectedProxies = List.from(widget.selectedProxies);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Proxies'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context, _selectedProxies);
            },
            icon: const Icon(Icons.check),
            label: Text('Done (${_selectedProxies.length})'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selected proxies
          _selectedProxies.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Proxies (${_selectedProxies.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedProxies.asMap().entries.map((entry) {
                            final index = entry.key;
                            final proxy = entry.value;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text('${index + 1}. ${proxy.proxyName}'),
                                onDeleted: () {
                                  setState(() {
                                    _selectedProxies.removeAt(index);
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'No proxies selected yet. Select proxies to create a chain.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
          
          const Divider(),
          
          // Available proxies
          Expanded(
            child: _availableProxies.isEmpty
                ? const Center(
                    child: Text('No available proxies. Try refreshing.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableProxies.length,
                    itemBuilder: (context, index) {
                      final proxy = _availableProxies[index];
                      final isSelected = _selectedProxies.contains(proxy);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(proxy.country.substring(0, 1)),
                          ),
                          title: Text(proxy.proxyName),
                          subtitle: Text('${proxy.ipAddress}:${proxy.port}'),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected 
                                  ? Icons.remove_circle 
                                  : Icons.add_circle,
                              color: isSelected 
                                  ? Colors.red 
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedProxies.remove(proxy);
                                } else {
                                  _selectedProxies.add(proxy);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedProxies.remove(proxy);
                              } else {
                                _selectedProxies.add(proxy);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Reorder proxies
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Chain Order'),
              content: SizedBox(
                width: double.maxFinite,
                child: _selectedProxies.isEmpty
                    ? const Text('No proxies selected yet.')
                    : ReorderableListView(
                        shrinkWrap: true,
                        children: _selectedProxies.asMap().entries.map((entry) {
                          final index = entry.key;
                          final proxy = entry.value;
                          
                          return ListTile(
                            key: Key('proxy-$index'),
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(proxy.proxyName),
                            subtitle: Text('${proxy.ipAddress}:${proxy.port}'),
                          );
                        }).toList(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _selectedProxies.removeAt(oldIndex);
                            _selectedProxies.insert(newIndex, item);
                          });
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.reorder),
      ),
    );
  }
} 