import 'package:hape_vpn/domain/models/connection_log.dart';
import 'package:hape_vpn/domain/models/user_profile.dart';
import 'package:hape_vpn/domain/models/user_settings.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/infrastructure/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    final response = await _client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  @override
  Future<UserProfile> createUserProfile(String userId, String? displayName) async {
    final response = await _client
        .from('user_profiles')
        .insert({
          'id': userId,
          'display_name': displayName,
        })
        .select()
        .single();
    
    return UserProfile.fromJson(response);
  }

  @override
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _client
          .from('user_profiles')
          .update({
            'display_name': profile.displayName,
            'subscription_tier': profile.subscriptionTier,
            'subscription_expiry': profile.subscriptionExpiry?.toIso8601String(),
            'data_usage': profile.dataUsage,
            'max_data_limit': profile.maxDataLimit,
          })
          .eq('id', profile.id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserSettings> getUserSettings(String userId) async {
    final response = await _client
        .from('user_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    if (response == null) {
      // Create default settings if none exist
      final defaultSettings = {
        'user_id': userId,
      };
      
      final newSettings = await _client
          .from('user_settings')
          .insert(defaultSettings)
          .select()
          .single();
      
      return UserSettings.fromJson(newSettings);
    }
    
    return UserSettings.fromJson(response);
  }

  @override
  Future<bool> updateUserSettings(UserSettings settings) async {
    try {
      await _client
          .from('user_settings')
          .upsert({
            'user_id': settings.userId,
            'auto_connect': settings.autoConnect,
            'kill_switch_enabled': settings.killSwitchEnabled,
            'dns_leak_protection': settings.dnsLeakProtection,
            'split_tunneling_enabled': settings.splitTunnelingEnabled,
            'theme_preference': settings.themePreference,
            'last_connected_server': settings.lastConnectedServerId,
            'last_used_proxy_chain': settings.lastUsedProxyChainId,
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateDataUsage(String userId, int additionalData) async {
    try {
      await _client.rpc('increment_data_usage', params: {
        'user_id_param': userId,
        'data_amount': additionalData,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ConnectionLog>> getConnectionLogs(String userId, {int limit = 10}) async {
    final response = await _client
        .from('connection_logs')
        .select()
        .eq('user_id', userId)
        .order('connected_at', ascending: false)
        .limit(limit);
    
    return response.map((json) => ConnectionLog.fromJson(json)).toList();
  }

  @override
  Future<bool> logConnection(ConnectionLog log) async {
    try {
      await _client
          .from('connection_logs')
          .insert({
            'user_id': log.userId,
            'server_id': log.serverId,
            'connected_at': log.connectedAt.toIso8601String(),
            'connection_status': log.connectionStatus,
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateConnectionLog(String logId, DateTime disconnectedAt, int dataUsed) async {
    try {
      await _client
          .from('connection_logs')
          .update({
            'disconnected_at': disconnectedAt.toIso8601String(),
            'data_used': dataUsed,
            'connection_status': 'disconnected',
          })
          .eq('id', logId);
      return true;
    } catch (e) {
      return false;
    }
  }
} 