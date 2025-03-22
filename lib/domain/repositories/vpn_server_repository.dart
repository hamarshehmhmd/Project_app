import '../models/vpn_server.dart';

abstract class VpnServerRepository {
  Future<List<VpnServer>> getAllServers();
  Future<List<VpnServer>> getServersByCountry(String country);
  Future<VpnServer?> getServerById(String id);
  Future<List<VpnServer>> getFavoriteServers(String userId);
  Future<bool> addFavoriteServer(String userId, String serverId);
  Future<bool> removeFavoriteServer(String userId, String serverId);
} 