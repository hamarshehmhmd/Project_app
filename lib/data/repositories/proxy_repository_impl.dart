import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/proxy_server.dart';
import 'package:hape_vpn/domain/repositories/proxy_repository.dart';
import 'package:hape_vpn/infrastructure/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProxyRepositoryImpl implements ProxyRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<ProxyServer>> getAllProxyServers() async {
    final response = await _client
        .from('proxy_servers')
        .select()
        .eq('is_active', true)
        .order('country');
    
    return response.map((json) => ProxyServer.fromJson(json)).toList();
  }

  @override
  Future<ProxyServer?> getProxyServerById(String id) async {
    final response = await _client
        .from('proxy_servers')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return ProxyServer.fromJson(response);
  }

  @override
  Future<List<ProxyChain>> getUserProxyChains(String userId) async {
    final response = await _client
        .from('proxy_chains')
        .select('*, proxy_chain_items(*, proxy_servers(*))')
        .eq('user_id', userId)
        .order('created_at');
    
    return response.map((json) {
      final chain = ProxyChain.fromJson(json);
      final items = (json['proxy_chain_items'] as List).map((item) {
        return ProxyChainItem(
          id: item['id'],
          chainId: item['chain_id'],
          proxyId: item['proxy_id'],
          sequenceOrder: item['sequence_order'],
          proxyServer: item['proxy_servers'] != null 
              ? ProxyServer.fromJson(item['proxy_servers']) 
              : null,
        );
      }).toList();
      
      return chain.copyWith(items: items);
    }).toList();
  }

  @override
  Future<ProxyChain?> getProxyChainById(String id) async {
    final response = await _client
        .from('proxy_chains')
        .select('*, proxy_chain_items(*, proxy_servers(*))')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    
    final chain = ProxyChain.fromJson(response);
    final items = (response['proxy_chain_items'] as List).map((item) {
      return ProxyChainItem(
        id: item['id'],
        chainId: item['chain_id'],
        proxyId: item['proxy_id'],
        sequenceOrder: item['sequence_order'],
        proxyServer: item['proxy_servers'] != null 
            ? ProxyServer.fromJson(item['proxy_servers']) 
            : null,
      );
    }).toList();
    
    return chain.copyWith(items: items);
  }

  @override
  Future<ProxyChain> createProxyChain(String userId, String chainName) async {
    final response = await _client
        .from('proxy_chains')
        .insert({
          'user_id': userId,
          'chain_name': chainName,
        })
        .select()
        .single();
    
    return ProxyChain.fromJson(response);
  }

  @override
  Future<bool> updateProxyChain(ProxyChain chain) async {
    try {
      await _client
          .from('proxy_chains')
          .update({
            'chain_name': chain.chainName,
            'is_active': chain.isActive,
          })
          .eq('id', chain.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteProxyChain(String id) async {
    try {
      await _client
          .from('proxy_chains')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addProxyToChain(String chainId, String proxyId, int order) async {
    try {
      await _client
          .from('proxy_chain_items')
          .insert({
            'chain_id': chainId,
            'proxy_id': proxyId,
            'sequence_order': order,
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeProxyFromChain(String chainItemId) async {
    try {
      await _client
          .from('proxy_chain_items')
          .delete()
          .eq('id', chainItemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateProxyOrder(String chainItemId, int newOrder) async {
    try {
      await _client
          .from('proxy_chain_items')
          .update({
            'sequence_order': newOrder,
          })
          .eq('id', chainItemId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setActiveChain(String userId, String? chainId) async {
    try {
      // First deactivate all chains for this user
      await _client
          .from('proxy_chains')
          .update({'is_active': false})
          .eq('user_id', userId);
      
      // If a chain ID is provided, activate it
      if (chainId != null) {
        await _client
            .from('proxy_chains')
            .update({'is_active': true})
            .eq('id', chainId)
            .eq('user_id', userId);
      }
      
      // Update user settings with the last used chain
      await _client
          .from('user_settings')
          .upsert({
            'user_id': userId,
            'last_used_proxy_chain': chainId,
          });
          
      return true;
    } catch (e) {
      return false;
    }
  }
} 