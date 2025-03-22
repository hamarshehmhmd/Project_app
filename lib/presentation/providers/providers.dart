import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/data/repositories/proxy_repository_impl.dart';
import 'package:hape_vpn/data/repositories/user_repository_impl.dart';
import 'package:hape_vpn/data/repositories/vpn_server_repository_impl.dart';
import 'package:hape_vpn/domain/repositories/proxy_repository.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/domain/repositories/vpn_server_repository.dart';
import 'package:hape_vpn/domain/usecases/auth_usecases.dart';
import 'package:hape_vpn/domain/usecases/proxy_usecases.dart';
import 'package:hape_vpn/domain/usecases/vpn_usecases.dart';
import 'package:hape_vpn/infrastructure/proxy/proxy_chain_service.dart';
import 'package:hape_vpn/infrastructure/vpn/vpn_service.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';
import 'package:hape_vpn/presentation/providers/proxy_provider.dart';
import 'package:hape_vpn/presentation/providers/settings_provider.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';

// Services
final vpnServiceProvider = Provider<VpnService>((ref) => VpnService());
final proxyChainServiceProvider = Provider<ProxyChainService>((ref) => ProxyChainService());

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl();
});

final vpnServerRepositoryProvider = Provider<VpnServerRepository>((ref) {
  return VpnServerRepositoryImpl();
});

final proxyRepositoryProvider = Provider<ProxyRepository>((ref) {
  return ProxyRepositoryImpl();
});

// Auth UseCases
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(userRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(userRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase();
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(userRepositoryProvider));
});

// VPN UseCases
final connectToVpnUseCaseProvider = Provider<ConnectToVpnUseCase>((ref) {
  return ConnectToVpnUseCase(
    ref.watch(vpnServiceProvider),
    ref.watch(userRepositoryProvider),
  );
});

final disconnectFromVpnUseCaseProvider = Provider<DisconnectFromVpnUseCase>((ref) {
  return DisconnectFromVpnUseCase(
    ref.watch(vpnServiceProvider),
    ref.watch(userRepositoryProvider),
  );
});

final getRecommendedServersUseCaseProvider = Provider<GetRecommendedServersUseCase>((ref) {
  return GetRecommendedServersUseCase(ref.watch(vpnServerRepositoryProvider));
});

final toggleFavoriteServerUseCaseProvider = Provider<ToggleFavoriteServerUseCase>((ref) {
  return ToggleFavoriteServerUseCase(ref.watch(vpnServerRepositoryProvider));
});

// Proxy UseCases
final activateProxyChainUseCaseProvider = Provider<ActivateProxyChainUseCase>((ref) {
  return ActivateProxyChainUseCase(
    ref.watch(proxyChainServiceProvider),
    ref.watch(proxyRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

final deactivateProxyChainUseCaseProvider = Provider<DeactivateProxyChainUseCase>((ref) {
  return DeactivateProxyChainUseCase(
    ref.watch(proxyChainServiceProvider),
    ref.watch(proxyRepositoryProvider),
  );
});

final createProxyChainUseCaseProvider = Provider<CreateProxyChainUseCase>((ref) {
  return CreateProxyChainUseCase(ref.watch(proxyRepositoryProvider));
});

final deleteProxyChainUseCaseProvider = Provider<DeleteProxyChainUseCase>((ref) {
  return DeleteProxyChainUseCase(
    ref.watch(proxyRepositoryProvider),
    ref.watch(proxyChainServiceProvider),
  );
});

// State Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(signInUseCaseProvider),
    ref.watch(signUpUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(getCurrentUserUseCaseProvider),
  );
});

final vpnProvider = StateNotifierProvider<VpnNotifier, VpnState>((ref) {
  return VpnNotifier(
    ref.watch(vpnServiceProvider),
    ref.watch(connectToVpnUseCaseProvider),
    ref.watch(disconnectFromVpnUseCaseProvider),
    ref.watch(getRecommendedServersUseCaseProvider),
    ref.watch(toggleFavoriteServerUseCaseProvider),
    ref.watch(authProvider),
  );
});

final proxyProvider = StateNotifierProvider<ProxyNotifier, ProxyState>((ref) {
  return ProxyNotifier(
    ref.watch(proxyChainServiceProvider),
    ref.watch(activateProxyChainUseCaseProvider),
    ref.watch(deactivateProxyChainUseCaseProvider),
    ref.watch(createProxyChainUseCaseProvider),
    ref.watch(deleteProxyChainUseCaseProvider),
    ref.watch(proxyRepositoryProvider),
    ref.watch(authProvider),
  );
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(
    ref.watch(userRepositoryProvider),
    ref.watch(authProvider),
  );
}); 