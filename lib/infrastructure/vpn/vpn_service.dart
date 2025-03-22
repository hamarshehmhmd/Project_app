import 'dart:async';
import 'dart:io';
import 'package:flutter_openvpn/flutter_openvpn.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';

enum VpnStatus {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnService {
  static final VpnService _instance = VpnService._internal();
  factory VpnService() => _instance;
  VpnService._internal();
  
  VpnStatus _status = VpnStatus.disconnected;
  VpnServer? _currentServer;
  StreamController<VpnStatus> _statusController = StreamController<VpnStatus>.broadcast();
  DateTime? _connectionStartTime;
  Timer? _dataUsageTimer;
  int _dataUsed = 0;
  
  VpnStatus get status => _status;
  Stream<VpnStatus> get statusStream => _statusController.stream;
  VpnServer? get currentServer => _currentServer;
  DateTime? get connectionStartTime => _connectionStartTime;
  int get dataUsed => _dataUsed;
  
  Future<bool> initialize() async {
    try {
      await FlutterOpenvpn.init(
        localizedDescription: "Hape VPN",
        providerBundleIdentifier: "com.hape.vpn.network-extension",
      );
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> connect(VpnServer server, {String? username, String? password}) async {
    if (_status == VpnStatus.connecting || _status == VpnStatus.connected) {
      await disconnect();
    }
    
    _updateStatus(VpnStatus.connecting);
    _currentServer = server;
    _connectionStartTime = DateTime.now();
    _dataUsed = 0;
    _startDataUsageTracking();
    
    try {
      final config = await _getConfigForServer(server);
      
      await FlutterOpenvpn.connect(
        config,
        server.serverName,
        username: username,
        password: password,
        certIsRequired: false,
        onConnectionStatusChanged: (status) {
          _handleStatusChange(status);
        },
      );
      
      return true;
    } catch (e) {
      _updateStatus(VpnStatus.error);
      return false;
    }
  }
  
  Future<bool> disconnect() async {
    if (_status == VpnStatus.disconnected) {
      return true;
    }
    
    _updateStatus(VpnStatus.disconnecting);
    _stopDataUsageTracking();
    
    try {
      await FlutterOpenvpn.disconnect();
      _updateStatus(VpnStatus.disconnected);
      _currentServer = null;
      _connectionStartTime = null;
      return true;
    } catch (e) {
      _updateStatus(VpnStatus.error);
      return false;
    }
  }
  
  void _handleStatusChange(String status) {
    if (status.toLowerCase().contains('connected')) {
      _updateStatus(VpnStatus.connected);
    } else if (status.toLowerCase().contains('disconnected')) {
      _updateStatus(VpnStatus.disconnected);
      _stopDataUsageTracking();
    } else if (status.toLowerCase().contains('error')) {
      _updateStatus(VpnStatus.error);
      _stopDataUsageTracking();
    }
  }
  
  void _updateStatus(VpnStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }
  
  Future<String> _getConfigForServer(VpnServer server) async {
    // This is a sample OpenVPN config. In a real app, you'd fetch this from your backend
    // or generate it based on server details.
    return '''
client
dev tun
proto ${server.protocol.toLowerCase()}
remote ${server.ipAddress} ${server.port}
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-CBC
auth SHA256
verb 3
''';
  }
  
  void _startDataUsageTracking() {
    _dataUsageTimer?.cancel();
    _dataUsageTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      // This is a simplified simulation. In a real app, you'd use platform-specific
      // methods to get actual data usage from the VPN interface.
      if (_status == VpnStatus.connected) {
        // Simulate random data usage between 5KB and 50KB per second
        final random = 5000 + DateTime.now().microsecond % 45000;
        _dataUsed += random;
      }
    });
  }
  
  void _stopDataUsageTracking() {
    _dataUsageTimer?.cancel();
    _dataUsageTimer = null;
  }
  
  void dispose() {
    _statusController.close();
    _dataUsageTimer?.cancel();
  }
} 