import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/connection_log.dart';
import 'package:hape_vpn/domain/models/user_settings.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';

class SettingsState {
  final UserSettings? settings;
  final List<ConnectionLog> recentLogs;
  final bool isLoading;
  final String? errorMessage;

  SettingsState({
    this.settings,
    this.recentLogs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory SettingsState.initial() {
    return SettingsState();
  }

  SettingsState copyWith({
    UserSettings? settings,
    List<ConnectionLog>? recentLogs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      recentLogs: recentLogs ?? this.recentLogs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final UserRepository _userRepository;
  final AuthState _authState;

  SettingsNotifier(this._userRepository, this._authState) : super(SettingsState.initial()) {
    if (_authState.status == AuthStatus.authenticated) {
      _loadSettings();
      _loadConnectionLogs();
    }
  }

  Future<void> _loadSettings() async {
    if (_authState.user == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final settings = await _userRepository.getUserSettings(_authState.user!.id);
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load settings',
        isLoading: false,
      );
    }
  }

  Future<void> _loadConnectionLogs() async {
    if (_authState.user == null) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final logs = await _userRepository.getConnectionLogs(_authState.user!.id);
      state = state.copyWith(
        recentLogs: logs,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load connection logs',
        isLoading: false,
      );
    }
  }

  Future<void> updateSettings(UserSettings settings) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final success = await _userRepository.updateUserSettings(settings);
      
      if (success) {
        state = state.copyWith(
          settings: settings,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to update settings',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to update settings',
        isLoading: false,
      );
    }
  }

  Future<void> toggleAutoConnect(bool value) async {
    if (state.settings == null) return;
    
    final updatedSettings = state.settings!.copyWith(autoConnect: value);
    await updateSettings(updatedSettings);
  }

  Future<void> toggleKillSwitch(bool value) async {
    if (state.settings == null) return;
    
    final updatedSettings = state.settings!.copyWith(killSwitchEnabled: value);
    await updateSettings(updatedSettings);
  }

  Future<void> toggleDnsLeakProtection(bool value) async {
    if (state.settings == null) return;
    
    final updatedSettings = state.settings!.copyWith(dnsLeakProtection: value);
    await updateSettings(updatedSettings);
  }

  Future<void> toggleSplitTunneling(bool value) async {
    if (state.settings == null) return;
    
    final updatedSettings = state.settings!.copyWith(splitTunnelingEnabled: value);
    await updateSettings(updatedSettings);
  }

  Future<void> updateThemePreference(String theme) async {
    if (state.settings == null) return;
    
    final updatedSettings = state.settings!.copyWith(themePreference: theme);
    await updateSettings(updatedSettings);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void refreshData() {
    _loadSettings();
    _loadConnectionLogs();
  }
} 