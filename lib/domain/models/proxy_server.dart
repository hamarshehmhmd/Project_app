import 'package:freezed_annotation/freezed_annotation.dart';

part 'proxy_server.freezed.dart';
part 'proxy_server.g.dart';

@freezed
class ProxyServer with _$ProxyServer {
  const factory ProxyServer({
    required String id,
    required String proxyName,
    required String proxyType,
    required String country,
    String? city,
    required String ipAddress,
    required int port,
    String? username,
    String? password,
    @Default(false) bool isPremium,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _ProxyServer;

  factory ProxyServer.fromJson(Map<String, dynamic> json) => _$ProxyServerFromJson(json);
} 