import 'package:freezed_annotation/freezed_annotation.dart';
import 'proxy_server.dart';

part 'proxy_chain.freezed.dart';
part 'proxy_chain.g.dart';

@freezed
class ProxyChain with _$ProxyChain {
  const factory ProxyChain({
    required String id,
    required String userId,
    required String chainName,
    @Default(false) bool isActive,
    required DateTime createdAt,
    @Default([]) List<ProxyChainItem> items,
  }) = _ProxyChain;

  factory ProxyChain.fromJson(Map<String, dynamic> json) => _$ProxyChainFromJson(json);
}

@freezed
class ProxyChainItem with _$ProxyChainItem {
  const factory ProxyChainItem({
    required String id,
    required String chainId,
    required String proxyId,
    required int sequenceOrder,
    ProxyServer? proxyServer,
  }) = _ProxyChainItem;

  factory ProxyChainItem.fromJson(Map<String, dynamic> json) => _$ProxyChainItemFromJson(json);
} 