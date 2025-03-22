import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/domain/usecases/vpn_usecases.dart';
import 'package:hape_vpn/infrastructure/vpn/vpn_service.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';

class VpnState {
  final VpnStatus status;
  final VpnServer? currentServer;
  final List<VpnServer> recommendedServers;
  final List<VpnServer> favoriteServers;
  final bool isInitialized;
  final int dataUsage;
  final String? errorMessage;

  VpnState({
    required this.status,
    this.currentServer,
    this.recommendedServers = const [],
    this.favoriteServers = const [],
    this.isInitialized = false,
    this.dataUsage = 0,
    this.errorMessage,
  });

  factory VpnState.initial() {
    return VpnState(status: VpnStatus.disconnected);
  }

  VpnState copyWith({
    VpnStatus? status,
    VpnServer? currentServer,
    List<VpnServer>? recommendedServers,
    List<VpnServer>? favoriteServers,
    bool? isInitialized,
    int? dataUsage,
    String? errorMessage,
  }) {
    return VpnState(
      status: status ?? this.status,
      currentServer: currentServer ?? this.currentServer,
      recommendedServers: recommendedServers ?? this.recommendedServers,
      favoriteServers: favoriteServers ?? this.favoriteServers,
      isInitialized: isInitialized ?? this.isInitialized,
      dataUsage: dataUsage ?? this.dataUsage,
      errorMessage: errorMessage,
    );
  }
}

class VpnNotifier extends StateNotifier<VpnState> {
  final VpnService _vpnService;
  final ConnectToVpnUseCase _connectToVpnUseCase;
  final DisconnectFromVpnUseCase _disconnectFromVpnUseCase;
  final GetRecommendedServersUseCase _getRecommendedServersUseCase;
  final ToggleFavoriteServerUseCase _toggleFavoriteServerUseCase;
  final AuthState _authState;
  
  StreamSubscription<VpnStatus>? _vpnStatusSubscription;
  Timer? _dataUsageTimer;

  VpnNotifier(
    this._vpnService,
    this._connectToVpnUseCase,
    this._disconnectFromVpnUseCase,
    this._getRecommendedServersUseCase,
    this._toggleFavoriteServerUseCase,
    this._authState,
  ) : super(VpnState.initial()) {
    _initialize();
    _startListeningToVpnStatus();
    _startDataUsageTracking();
  }

  Future<void> _initialize() async {
    final initialized = await _vpnService.initialize();
    state = state.copyWith(isInitialized: initialized);
    
    if (initialized && _authState.status == AuthStatus.authenticated) {
      await loadRecommendedServers();
    }
  }

  void _startListeningToVpnStatus() {
    _vpnStatusSubscription = _vpnService.statusStream.listen((status) {
      state = state.copyWith(
        status: status,
        currentServer: _vpnService.currentServer,
      );
    });
  }

  void _startDataUsageTracking() {
    _dataUsageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (state.status == VpnStatus.connected) {
        state = state.copyWith(dataUsage: _vpnService.dataUsed);
      }
    });
  }

  Future<void> loadRecommendedServers() async {
    if (_authState.user == null) return;
    
    final servers = await _getRecommendedServersUseCase.execute();
    state = state.copyWith(recommendedServers: servers);
  }

  Future<void> loadFavoriteServers() async {
    if (_authState.user == null) return;
    
    final servers = await _vpnService as List<VpnServer>;
    state = state.copyWith(favoriteServers: servers);
  }

  Future<void> connect(VpnServer server) async {
    if (!state.isInitialized || _authState.user == null) return;
    
    final success = await _connectToVpnUseCase.execute(_authState.user!.id, server);
    
    if (!success) {
      state = state.copyWith(errorMessage: 'Failed to connect to VPN');
    }
  }

  Future<void> disconnect() async {
    if (_authState.user == null) return;
    
    final success = await _disconnectFromVpnUseCase.execute(_authState.user!.id);
    
    if (!success) {
      state = state.copyWith(errorMessage: 'Failed to disconnect from VPN');
    }
  }

  Future<void> toggleFavorite(VpnServer server, bool isFavorite) async {
    if (_authState.user == null) return;
    
    final success = await _toggleFavoriteServerUseCase.execute(
      _authState.user!.id,
      server.id,
      isFavorite,
    );
    
    if (success) {
      await loadFavoriteServers();
    } else {
      state = state.copyWith(errorMessage: 'Failed to update favorite servers');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _vpnStatusSubscription?.cancel();
    _dataUsageTimer?.cancel();
    super.dispose();
  }
} 