import '../models/proxy_chain.dart';
import '../models/proxy_server.dart';

abstract class ProxyRepository {
  Future<List<ProxyServer>> getAllProxyServers();
  Future<ProxyServer?> getProxyServerById(String id);
  Future<List<ProxyChain>> getUserProxyChains(String userId);
  Future<ProxyChain?> getProxyChainById(String id);
  Future<ProxyChain> createProxyChain(String userId, String chainName);
  Future<bool> updateProxyChain(ProxyChain chain);
  Future<bool> deleteProxyChain(String id);
  Future<bool> addProxyToChain(String chainId, String proxyId, int order);
  Future<bool> removeProxyFromChain(String chainItemId);
  Future<bool> updateProxyOrder(String chainItemId, int newOrder);
  Future<bool> setActiveChain(String userId, String? chainId);
} 