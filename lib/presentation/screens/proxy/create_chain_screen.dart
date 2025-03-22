import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/presentation/providers/proxy_provider.dart';
import 'package:hape_vpn/presentation/providers/server_provider.dart';

class CreateChainScreen extends ConsumerStatefulWidget {
  final ProxyChain? existingChain;
  
  const CreateChainScreen({
    super.key,
    this.existingChain,
  });

  @override
  ConsumerState<CreateChainScreen> createState() => _CreateChainScreenState();
}

class _CreateChainScreenState extends ConsumerState<CreateChainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<VpnServer> _selectedServers = [];
  bool _isLoading = false;
  
  bool get _isEditing => widget.existingChain != null;
  
  @override
  void initState() {
    super.initState();
    
    // Load available servers
    Future.microtask(() async {
      await ref.read(serverProvider.notifier).loadAllServers();
    });
    
    // If editing an existing chain, populate the form fields
    if (_isEditing) {
      _nameController.text = widget.existingChain!.name;
      _selectedServers.addAll(widget.existingChain!.servers);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Proxy Chain' : 'Create Proxy Chain'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Chain name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Chain Name',
                      hintText: 'Enter a name for your proxy chain',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for your proxy chain';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Selected Servers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Selected servers list
                  if (_selectedServers.isEmpty) ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'No servers selected yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ] else ...[
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedServers.length,
                      itemBuilder: (context, index) {
                        final server = _selectedServers[index];
                        return ListTile(
                          key: ValueKey(server.id),
                          title: Text(server.serverName),
                          subtitle: Text(
                            '${server.country}${server.city != null ? ', ${server.city}' : ''}',
                          ),
                          leading: const Icon(Icons.public),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _selectedServers.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final item = _selectedServers.removeAt(oldIndex);
                          _selectedServers.insert(newIndex, item);
                        });
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Add server button
                  ElevatedButton.icon(
                    onPressed: () => _showServerSelectionDialog(serverState.allServers),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Server to Chain'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Guidelines and information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How Proxy Chains Work',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Each server in the chain routes your traffic to the next server\n'
                            '• The more servers in the chain, the more secure but slower\n'
                            '• Drag servers to reorder them in the chain\n'
                            '• Premium servers provide better speeds in chains',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom action buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChain,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isEditing ? 'Update Chain' : 'Create Chain'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showServerSelectionDialog(List<VpnServer> availableServers) {
    // Filter out already selected servers
    final selectableServers = availableServers
        .where((server) => !_selectedServers.any((s) => s.id == server.id))
        .toList();
    
    if (selectableServers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All available servers have already been added to this chain.'),
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Server'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: selectableServers.length,
            itemBuilder: (context, index) {
              final server = selectableServers[index];
              return ListTile(
                title: Text(server.serverName),
                subtitle: Text('${server.country}${server.city != null ? ', ${server.city}' : ''}'),
                leading: server.isPremium
                    ? const Icon(Icons.star, color: Colors.amber)
                    : const Icon(Icons.public),
                onTap: () {
                  setState(() {
                    _selectedServers.add(server);
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
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
  
  Future<void> _saveChain() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedServers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one server to your proxy chain.'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final name = _nameController.text.trim();
      
      if (_isEditing) {
        // Update existing chain
        final updatedChain = widget.existingChain!.copyWith(
          name: name,
          servers: _selectedServers,
        );
        
        await ref.read(proxyProvider.notifier).updateChain(updatedChain);
      } else {
        // Create new chain
        await ref.read(proxyProvider.notifier).createChain(
          name: name,
          servers: _selectedServers,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 