import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/domain/repositories/vpn_server_repository.dart';
import 'package:hape_vpn/infrastructure/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VpnServerRepositoryImpl implements VpnServerRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<List<VpnServer>> getAllServers() async {
    final response = await _client
        .from('vpn_servers')
        .select()
        .eq('is_active', true)
        .order('country');
    
    return response.map((json) => VpnServer.fromJson(json)).toList();
  }

  @override
  Future<List<VpnServer>> getServersByCountry(String country) async {
    final response = await _client
        .from('vpn_servers')
        .select()
        .eq('country', country)
        .eq('is_active', true)
        .order('server_name');
    
    return response.map((json) => VpnServer.fromJson(json)).toList();
  }

  @override
  Future<VpnServer?> getServerById(String id) async {
    final response = await _client
        .from('vpn_servers')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return VpnServer.fromJson(response);
  }

  @override
  Future<List<VpnServer>> getFavoriteServers(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('vpn_servers(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return response.map((json) => 
      VpnServer.fromJson(json['vpn_servers'])
    ).toList();
  }

  @override
  Future<bool> addFavoriteServer(String userId, String serverId) async {
    try {
      await _client.from('user_favorites').insert({
        'user_id': userId,
        'server_id': serverId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeFavoriteServer(String userId, String serverId) async {
    try {
      await _client
          .from('user_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('server_id', serverId);
      return true;
    } catch (e) {
      return false;
    }
  }
} 