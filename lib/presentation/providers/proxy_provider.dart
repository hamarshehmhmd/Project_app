import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/proxy_server.dart';
import 'package:hape_vpn/domain/repositories/proxy_repository.dart';
import 'package:hape_vpn/domain/usecases/proxy_usecases.dart';
import 'package:hape_vpn/infrastructure/proxy/proxy_chain_service.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

final proxyProvider = StateNotifierProvider<ProxyNotifier, ProxyState>((ref) {
  final authState = ref.watch(authProvider);
  final service = ProxyChainService();
  final implementation = ProxyChainImplementation(service);
  
  return ProxyNotifier(
    service, 
    implementation,
    authState.user?.id,
  );
});

class ProxyState {
  final ProxyStatus status;
  final List<ProxyChain> chains;
  final ProxyChain? activeChain;
  final List<ProxyServer> availableProxies;
  final bool isLoading;
  final String? errorMessage;
  final String? userId;

  ProxyState({
    required this.status,
    this.chains = const [],
    this.activeChain,
    this.availableProxies = const [],
    this.isLoading = false,
    this.errorMessage,
    this.userId,
  });

  ProxyState copyWith({
    ProxyStatus? status,
    List<ProxyChain>? chains,
    ProxyChain? activeChain,
    List<ProxyServer>? availableProxies,
    bool? isLoading,
    String? errorMessage,
    String? userId,
  }) {
    return ProxyState(
      status: status ?? this.status,
      chains: chains ?? this.chains,
      activeChain: activeChain,
      availableProxies: availableProxies ?? this.availableProxies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
    );
  }
}

class ProxyNotifier extends StateNotifier<ProxyState> {
  final ProxyChainService _service;
  final ProxyChainImplementation _implementation;
  
  ProxyNotifier(
    this._service,
    this._implementation,
    String? userId,
  ) : super(ProxyState(
      status: ProxyStatus.inactive,
      userId: userId,
    )) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    
    // Initialize the proxy implementation
    await _implementation.initialize();
    
    // Load saved chains from storage
    await _loadSavedChains();
    
    // Load available proxies
    await fetchPublicProxies();
    
    state = state.copyWith(isLoading: false);
  }
  
  Future<void> _loadSavedChains() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chainsJson = prefs.getStringList('proxy_chains_${state.userId}');
      
      if (chainsJson != null) {
        final chains = chainsJson
            .map((json) => ProxyChain.fromJson(jsonDecode(json)))
            .toList();
        
        state = state.copyWith(chains: chains);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load saved proxy chains: $e',
      );
    }
  }
  
  Future<void> _saveChains() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chainsJson = state.chains
          .map((chain) => jsonEncode(chain.toJson()))
          .toList();
      
      await prefs.setStringList('proxy_chains_${state.userId}', chainsJson);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save proxy chains: $e',
      );
    }
  }
  
  Future<void> fetchPublicProxies() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Fetch basic proxy list
      final proxies = await _implementation.fetchPublicProxies();
      
      if (proxies.isNotEmpty) {
        // Enhance proxies with additional information (country, city, etc.)
        // Only process first 20 proxies to keep it manageable
        final proxiesToEnhance = proxies.length > 20 
            ? proxies.sublist(0, 20) 
            : proxies;
            
        final enhancedProxies = await _implementation.enhanceProxiesInfo(proxiesToEnhance);
        
        state = state.copyWith(
          availableProxies: enhancedProxies,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          availableProxies: proxies,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to fetch public proxies: $e',
        isLoading: false,
      );
    }
  }
  
  Future<void> createProxyChain(ProxyChain chain) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final existingChains = [...state.chains];
      existingChains.add(chain);
      
      state = state.copyWith(
        chains: existingChains,
        isLoading: false,
      );
      
      await _saveChains();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create proxy chain: $e',
        isLoading: false,
      );
    }
  }
  
  Future<void> updateProxyChain(ProxyChain updatedChain) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final existingChains = [...state.chains];
      final index = existingChains.indexWhere((c) => c.id == updatedChain.id);
      
      if (index >= 0) {
        existingChains[index] = updatedChain;
        
        state = state.copyWith(
          chains: existingChains,
          isLoading: false,
        );
        
        await _saveChains();
      } else {
        state = state.copyWith(
          errorMessage: 'Chain not found',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update proxy chain: $e',
        isLoading: false,
      );
    }
  }
  
  Future<void> deleteProxyChain(String chainId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final existingChains = [...state.chains];
      final index = existingChains.indexWhere((c) => c.id == chainId);
      
      if (index >= 0) {
        // If this is the active chain, deactivate it first
        if (state.activeChain?.id == chainId) {
          await deactivateProxyChain();
        }
        
        existingChains.removeAt(index);
        
        state = state.copyWith(
          chains: existingChains,
          isLoading: false,
        );
        
        await _saveChains();
      } else {
        state = state.copyWith(
          errorMessage: 'Chain not found',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete proxy chain: $e',
        isLoading: false,
      );
    }
  }
  
  Future<void> activateProxyChain(ProxyChain chain) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // If another chain is active, deactivate it first
      if (state.status == ProxyStatus.active) {
        await deactivateProxyChain();
      }
      
      // Start the proxy chain
      final success = await _implementation.startProxyChain(chain);
      
      if (success) {
        state = state.copyWith(
          status: ProxyStatus.active,
          activeChain: chain,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to activate proxy chain',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to activate proxy chain: $e',
        isLoading: false,
      );
    }
  }
  
  Future<void> deactivateProxyChain() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Stop the proxy chain
      final success = await _implementation.stopProxyChain();
      
      if (success) {
        state = state.copyWith(
          status: ProxyStatus.inactive,
          activeChain: null,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to deactivate proxy chain',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to deactivate proxy chain: $e',
        isLoading: false,
      );
    }
  }
  
  Future<int> testProxyChainSpeed(ProxyChain chain) async {
    try {
      return await _service.testProxyChainSpeed(chain);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to test proxy chain speed: $e',
      );
      return 999; // High latency as fallback
    }
  }
  
  Future<bool> testProxyChainConnection(ProxyChain chain) async {
    try {
      return await _service.testProxyChainConnection(chain);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to test proxy chain connection: $e',
      );
      return false;
    }
  }
  
  /// Test the latency of a single proxy server
  Future<int> testProxyLatency(ProxyServer proxy) async {
    try {
      state = state.copyWith(isLoading: true);
      final latency = await _implementation.checkProxyLatency(proxy);
      state = state.copyWith(isLoading: false);
      return latency;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to test proxy latency: $e',
        isLoading: false,
      );
      return 9999; // High latency indicates failure
    }
  }
  
  /// Find the best proxy from the available proxies based on latency
  Future<ProxyServer?> findBestProxy() async {
    if (state.availableProxies.isEmpty) {
      await fetchPublicProxies();
      if (state.availableProxies.isEmpty) {
        return null;
      }
    }
    
    state = state.copyWith(isLoading: true);
    ProxyServer? bestProxy;
    int bestLatency = 10000;
    
    // Test a random sample of 5 proxies to find the best one
    final random = DateTime.now().millisecondsSinceEpoch;
    final sampleSize = state.availableProxies.length < 5 ? state.availableProxies.length : 5;
    final proxiesToTest = List<ProxyServer>.from(state.availableProxies)
      ..shuffle(Random(random));
    final samplesToTest = proxiesToTest.take(sampleSize).toList();
    
    for (final proxy in samplesToTest) {
      final latency = await _implementation.checkProxyLatency(proxy);
      if (latency < bestLatency && latency < 5000) { // Skip proxies with too high latency
        bestLatency = latency;
        bestProxy = proxy;
      }
    }
    
    state = state.copyWith(isLoading: false);
    return bestProxy;
  }
  
  /// Create a recommended chain with best available proxies
  Future<ProxyChain?> createRecommendedChain() async {
    if (state.userId == null) return null;
    
    state = state.copyWith(isLoading: true);
    
    try {
      // Find 2-3 good proxies
      final proxies = <ProxyServer>[];
      final bestProxy = await findBestProxy();
      
      if (bestProxy != null) {
        proxies.add(bestProxy);
        
        // Try to find a second good proxy
        final remainingProxies = state.availableProxies
            .where((p) => p.id != bestProxy.id)
            .toList();
            
        if (remainingProxies.isNotEmpty) {
          // Test a few more to find another good one
          final sampleSize = remainingProxies.length < 3 ? remainingProxies.length : 3;
          final testProxies = List<ProxyServer>.from(remainingProxies)
            ..shuffle();
          final samplesToTest = testProxies.take(sampleSize).toList();
          
          ProxyServer? secondBestProxy;
          int bestLatency = 10000;
          
          for (final proxy in samplesToTest) {
            final latency = await _implementation.checkProxyLatency(proxy);
            if (latency < bestLatency && latency < 5000) {
              bestLatency = latency;
              secondBestProxy = proxy;
            }
          }
          
          if (secondBestProxy != null) {
            proxies.add(secondBestProxy);
          }
        }
      }
      
      if (proxies.isEmpty) {
        state = state.copyWith(
          errorMessage: 'Could not find suitable proxies for a chain',
          isLoading: false,
        );
        return null;
      }
      
      // Create a new chain with the selected proxies
      final chain = ProxyChain(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: state.userId!,
        chainName: 'Recommended Chain',
        createdAt: DateTime.now(),
        items: proxies.asMap().entries.map((entry) {
          return ProxyChainItem(
            id: 'item-${entry.key}',
            chainId: DateTime.now().millisecondsSinceEpoch.toString(),
            proxyId: entry.value.id,
            sequenceOrder: entry.key,
            proxyServer: entry.value,
          );
        }).toList(),
      );
      
      // Save the chain
      await createProxyChain(chain);
      
      return chain;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to create recommended chain: $e',
        isLoading: false,
      );
      return null;
    }
  }
  
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
} 