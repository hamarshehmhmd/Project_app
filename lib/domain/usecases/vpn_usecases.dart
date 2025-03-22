import 'package:hape_vpn/domain/models/connection_log.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/domain/repositories/vpn_server_repository.dart';
import 'package:hape_vpn/infrastructure/vpn/vpn_service.dart';

class ConnectToVpnUseCase {
  final VpnService _vpnService;
  final UserRepository _userRepository;
  
  ConnectToVpnUseCase(this._vpnService, this._userRepository);
  
  Future<bool> execute(String userId, VpnServer server) async {
    // 1. Connect to VPN
    final success = await _vpnService.connect(server);
    
    if (success) {
      // 2. Log the connection
      final connectionLog = ConnectionLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        serverId: server.id,
        connectedAt: DateTime.now(),
        connectionStatus: 'connected',
      );
      
      await _userRepository.logConnection(connectionLog);
      
      // 3. Update user settings with last connected server
      final settings = await _userRepository.getUserSettings(userId);
      await _userRepository.updateUserSettings(
        settings.copyWith(lastConnectedServerId: server.id)
      );
    }
    
    return success;
  }
}

class DisconnectFromVpnUseCase {
  final VpnService _vpnService;
  final UserRepository _userRepository;
  
  DisconnectFromVpnUseCase(this._vpnService, this._userRepository);
  
  Future<bool> execute(String userId) async {
    final currentServer = _vpnService.currentServer;
    if (currentServer == null) return true;
    
    final dataUsed = _vpnService.dataUsed;
    final success = await _vpnService.disconnect();
    
    if (success) {
      // Find the most recent log for this connection
      final logs = await _userRepository.getConnectionLogs(userId, limit: 1);
      if (logs.isNotEmpty) {
        final latestLog = logs.first;
        // Update the log with disconnection info
        await _userRepository.updateConnectionLog(
          latestLog.id,
          DateTime.now(),
          dataUsed,
        );
      }
      
      // Update user's data usage
      await _userRepository.updateDataUsage(userId, dataUsed);
    }
    
    return success;
  }
}

class GetRecommendedServersUseCase {
  final VpnServerRepository _serverRepository;
  
  GetRecommendedServersUseCase(this._serverRepository);
  
  Future<List<VpnServer>> execute() async {
    final allServers = await _serverRepository.getAllServers();
    
    // Sort servers by load percentage (lowest first)
    allServers.sort((a, b) => a.loadPercentage.compareTo(b.loadPercentage));
    
    // Return the 5 least loaded servers
    return allServers.take(5).toList();
  }
}

class ToggleFavoriteServerUseCase {
  final VpnServerRepository _serverRepository;
  
  ToggleFavoriteServerUseCase(this._serverRepository);
  
  Future<bool> execute(String userId, String serverId, bool isFavorite) async {
    if (isFavorite) {
      return await _serverRepository.addFavoriteServer(userId, serverId);
    } else {
      return await _serverRepository.removeFavoriteServer(userId, serverId);
    }
  }
} 