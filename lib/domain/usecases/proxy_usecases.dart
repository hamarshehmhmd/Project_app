import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/user_settings.dart';
import 'package:hape_vpn/domain/repositories/proxy_repository.dart';
import 'package:hape_vpn/domain/repositories/user_repository.dart';
import 'package:hape_vpn/infrastructure/proxy/proxy_chain_service.dart';

class ActivateProxyChainUseCase {
  final ProxyChainService _proxyService;
  final ProxyRepository _proxyRepository;
  final UserRepository _userRepository;
  
  ActivateProxyChainUseCase(
    this._proxyService,
    this._proxyRepository,
    this._userRepository,
  );
  
  Future<bool> execute(String userId, String chainId) async {
    // 1. Get the proxy chain
    final chain = await _proxyRepository.getProxyChainById(chainId);
    if (chain == null) return false;
    
    // 2. Activate the proxy chain
    final success = await _proxyService.activateProxyChain(chain);
    
    if (success) {
      // 3. Update the active chain in database
      await _proxyRepository.setActiveChain(userId, chainId);
      
      // 4. Update user settings
      final settings = await _userRepository.getUserSettings(userId);
      await _userRepository.updateUserSettings(
        settings.copyWith(lastUsedProxyChainId: chainId)
      );
    }
    
    return success;
  }
}

class DeactivateProxyChainUseCase {
  final ProxyChainService _proxyService;
  final ProxyRepository _proxyRepository;
  
  DeactivateProxyChainUseCase(this._proxyService, this._proxyRepository);
  
  Future<bool> execute(String userId) async {
    final success = await _proxyService.deactivateProxyChain();
    
    if (success) {
      // Update the active chain in database (set to null)
      await _proxyRepository.setActiveChain(userId, null);
    }
    
    return success;
  }
}

class CreateProxyChainUseCase {
  final ProxyRepository _proxyRepository;
  
  CreateProxyChainUseCase(this._proxyRepository);
  
  Future<ProxyChain?> execute(String userId, String chainName) async {
    return await _proxyRepository.createProxyChain(userId, chainName);
  }
}

class DeleteProxyChainUseCase {
  final ProxyRepository _proxyRepository;
  final ProxyChainService _proxyService;
  
  DeleteProxyChainUseCase(this._proxyRepository, this._proxyService);
  
  Future<bool> execute(String userId, String chainId) async {
    // If this chain is active, deactivate it first
    final activeChain = _proxyService.activeChain;
    if (activeChain != null && activeChain.id == chainId) {
      await _proxyService.deactivateProxyChain();
      await _proxyRepository.setActiveChain(userId, null);
    }
    
    return await _proxyRepository.deleteProxyChain(chainId);
  }
}

class AddProxyToChainUseCase {
  final ProxyRepository _proxyRepository;
  
  AddProxyToChainUseCase(this._proxyRepository);
  
  Future<bool> execute(String chainId, String proxyId) async {
    // Get the current chain to determine the next order value
    final chain = await _proxyRepository.getProxyChainById(chainId);
    if (chain == null) return false;
    
    final nextOrder = chain.items.isEmpty 
        ? 1 
        : chain.items.map((item) => item.sequenceOrder).reduce((a, b) => a > b ? a : b) + 1;
    
    return await _proxyRepository.addProxyToChain(chainId, proxyId, nextOrder);
  }
}

class TestProxyChainUseCase {
  final ProxyChainService _proxyService;
  
  TestProxyChainUseCase(this._proxyService);
  
  Future<bool> execute(ProxyChain chain) async {
    return await _proxyService.testProxyChainConnection(chain);
  }
}

class MeasureProxyChainSpeedUseCase {
  final ProxyChainService _proxyService;
  
  MeasureProxyChainSpeedUseCase(this._proxyService);
  
  Future<int> execute(ProxyChain chain) async {
    return await _proxyService.testProxyChainSpeed(chain);
  }
} 