import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/presentation/providers/server_provider.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';
import 'package:hape_vpn/presentation/widgets/server_list.dart';

class ServerScreen extends ConsumerStatefulWidget {
  const ServerScreen({super.key});

  @override
  ConsumerState<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends ConsumerState<ServerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load servers on init
    Future.microtask(() async {
      await ref.read(serverProvider.notifier).loadAllServers();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverProvider);
    final filteredServers = _filterServers(serverState);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Servers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Servers'),
            Tab(text: 'Favorites'),
            Tab(text: 'Premium'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search servers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Server list with tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All servers tab
                _buildServersTabContent(
                  filteredServers.all,
                  'No servers found',
                  serverState.isLoading,
                ),
                
                // Favorites tab
                _buildServersTabContent(
                  filteredServers.favorite,
                  'No favorite servers yet',
                  serverState.isLoading,
                ),
                
                // Premium tab
                _buildServersTabContent(
                  filteredServers.premium,
                  'No premium servers available',
                  serverState.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServersTabContent(
    List<VpnServer> servers,
    String emptyMessage,
    bool isLoading,
  ) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (servers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(serverProvider.notifier).loadAllServers();
      },
      child: ListView(
        children: [
          ServerList(
            servers: servers,
            showTitle: false,
            physics: const AlwaysScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }
  
  // Filter servers based on the search query and tab
  _FilteredServers _filterServers(ServerState state) {
    if (_searchQuery.isEmpty) {
      return _FilteredServers(
        all: state.allServers,
        favorite: state.favoriteServers,
        premium: state.allServers.where((server) => server.isPremium).toList(),
      );
    }
    
    final query = _searchQuery.toLowerCase();
    
    final filteredAll = state.allServers.where((server) {
      return server.serverName.toLowerCase().contains(query) ||
          server.country.toLowerCase().contains(query) ||
          (server.city?.toLowerCase().contains(query) ?? false);
    }).toList();
    
    final filteredFavorite = state.favoriteServers.where((server) {
      return server.serverName.toLowerCase().contains(query) ||
          server.country.toLowerCase().contains(query) ||
          (server.city?.toLowerCase().contains(query) ?? false);
    }).toList();
    
    final filteredPremium = filteredAll.where((server) => server.isPremium).toList();
    
    return _FilteredServers(
      all: filteredAll,
      favorite: filteredFavorite,
      premium: filteredPremium,
    );
  }
}

class _FilteredServers {
  final List<VpnServer> all;
  final List<VpnServer> favorite;
  final List<VpnServer> premium;
  
  _FilteredServers({
    required this.all,
    required this.favorite,
    required this.premium,
  });
} 