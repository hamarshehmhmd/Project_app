import 'package:freezed_annotation/freezed_annotation.dart';

part 'vpn_server.freezed.dart';
part 'vpn_server.g.dart';

@freezed
class VpnServer with _$VpnServer {
  const factory VpnServer({
    required String id,
    required String serverName,
    required String country,
    String? city,
    required String ipAddress,
    required int port,
    required String protocol,
    @Default(0.0) double loadPercentage,
    @Default(false) bool isPremium,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _VpnServer;

  factory VpnServer.fromJson(Map<String, dynamic> json) => _$VpnServerFromJson(json);
} 