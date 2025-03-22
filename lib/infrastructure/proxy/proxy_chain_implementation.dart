import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:hape_vpn/domain/models/proxy_chain.dart';
import 'package:hape_vpn/domain/models/proxy_server.dart';
import 'package:hape_vpn/infrastructure/proxy/proxy_chain_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

/// Implementation of the proxy chain functionality
/// This uses the 3proxy open source proxy server under the hood
/// See: https://github.com/3proxy/3proxy
class ProxyChainImplementation {
  static const String _3PROXY_BINARY_ASSET_PATH = 'assets/binaries/3proxy';
  static const String _SHADOWSOCKS_BINARY_ASSET_PATH = 'assets/binaries/ss-local';
  
  final ProxyChainService _service;
  String? _binaryPath;
  String? _configPath;
  Process? _proxyProcess;
  int _localPort = 10800; // Starting local port
  
  ProxyChainImplementation(this._service);
  
  /// Initialize the proxy implementation by extracting necessary binaries
  Future<bool> initialize() async {
    try {
      // Get the app's documents directory to store binary and config files
      final appDocDir = await getApplicationDocumentsDirectory();
      final binDir = Directory('${appDocDir.path}/bin');
      
      if (!await binDir.exists()) {
        await binDir.create(recursive: true);
      }
      
      // Extract the 3proxy binary from assets
      _binaryPath = '${binDir.path}/3proxy';
      final file = File(_binaryPath!);
      
      if (!await file.exists()) {
        final byteData = await rootBundle.load(_3PROXY_BINARY_ASSET_PATH);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        // Make it executable
        await Process.run('chmod', ['+x', _binaryPath!]);
      }
      
      // Extract the shadowsocks binary from assets (for shadowsocks proxies)
      final ssLocalPath = '${binDir.path}/ss-local';
      final ssLocalFile = File(ssLocalPath);
      
      if (!await ssLocalFile.exists()) {
        final byteData = await rootBundle.load(_SHADOWSOCKS_BINARY_ASSET_PATH);
        await ssLocalFile.writeAsBytes(byteData.buffer.asUint8List());
        // Make it executable
        await Process.run('chmod', ['+x', ssLocalPath]);
      }
      
      return true;
    } catch (e) {
      print('Error initializing proxy chain implementation: $e');
      return false;
    }
  }
  
  /// Start a proxy chain with the given configuration
  Future<bool> startProxyChain(ProxyChain chain) async {
    if (_proxyProcess != null) {
      await stopProxyChain();
    }
    
    try {
      if (chain.items.isEmpty) {
        return false;
      }
      
      // Generate a configuration file for the chain
      final config = await _generateConfigFile(chain);
      if (config == null) {
        return false;
      }
      
      // Start the proxy process
      _proxyProcess = await Process.start(_binaryPath!, [config]);
      
      // Handle process output for logging
      _proxyProcess!.stdout.transform(utf8.decoder).listen((data) {
        print('Proxy stdout: $data');
      });
      
      _proxyProcess!.stderr.transform(utf8.decoder).listen((data) {
        print('Proxy stderr: $data');
      });
      
      // Wait a moment for the proxy to start
      await Future.delayed(const Duration(seconds: 1));
      
      // Verify proxy is working
      final isWorking = await _testProxyConnection(chain);
      if (!isWorking) {
        await stopProxyChain();
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error starting proxy chain: $e');
      return false;
    }
  }
  
  /// Stop the currently running proxy chain
  Future<bool> stopProxyChain() async {
    if (_proxyProcess == null) {
      return true;
    }
    
    try {
      _proxyProcess!.kill();
      _proxyProcess = null;
      
      // Clean up the configuration file
      if (_configPath != null) {
        final configFile = File(_configPath!);
        if (await configFile.exists()) {
          await configFile.delete();
        }
      }
      
      return true;
    } catch (e) {
      print('Error stopping proxy chain: $e');
      return false;
    }
  }
  
  /// Get the local proxy address for the app to use
  String? getLocalProxyAddress() {
    return 'socks5://127.0.0.1:$_localPort';
  }
  
  /// Fetch a list of available public SOCKS5 proxies
  Future<List<ProxyServer>> fetchPublicProxies() async {
    try {
      // Use ProxyScrape API with the provided API key
      final response = await http.get(Uri.parse(
        'https://api.proxyscrape.com/v2/?request=getproxies&protocol=socks5&timeout=10000&country=all&simplified=true&apiKey=w3jzjol9o815ajtbjrj'
      ));
      
      if (response.statusCode != 200) {
        return [];
      }
      
      final List<ProxyServer> proxies = [];
      final lines = const LineSplitter().convert(response.body);
      
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(':');
        if (parts.length != 2) continue;
        
        final ip = parts[0];
        final port = int.tryParse(parts[1]);
        if (port == null) continue;
        
        proxies.add(ProxyServer(
          id: 'public-${i+1}',
          proxyName: 'Public Proxy ${i+1}',
          proxyType: 'socks5',
          country: 'Unknown',
          ipAddress: ip,
          port: port,
          createdAt: DateTime.now(),
        ));
      }
      
      // If the response is empty or failed to parse, let's try the alternative endpoint
      if (proxies.isEmpty) {
        return await _fetchAlternativeProxies();
      }
      
      return proxies;
    } catch (e) {
      print('Error fetching public proxies: $e');
      return await _fetchAlternativeProxies();
    }
  }
  
  /// Fallback method to fetch proxies from alternative sources
  Future<List<ProxyServer>> _fetchAlternativeProxies() async {
    try {
      // Try an alternative source (ProxyScrape list API)
      final response = await http.get(Uri.parse(
        'https://api.proxyscrape.com/?request=displayproxies&proxytype=socks5&timeout=10000&country=all&apikey=w3jzjol9o815ajtbjrj'
      ));
      
      if (response.statusCode != 200) {
        return [];
      }
      
      final List<ProxyServer> proxies = [];
      final lines = const LineSplitter().convert(response.body);
      
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(':');
        if (parts.length != 2) continue;
        
        final ip = parts[0];
        final port = int.tryParse(parts[1]);
        if (port == null) continue;
        
        proxies.add(ProxyServer(
          id: 'public-${i+1}',
          proxyName: 'Public Proxy ${i+1}',
          proxyType: 'socks5',
          country: 'Unknown',
          ipAddress: ip,
          port: port,
          createdAt: DateTime.now(),
        ));
      }
      
      return proxies;
    } catch (e) {
      print('Error fetching alternative proxies: $e');
      return [];
    }
  }
  
  /// Test if the proxy chain is working by making a test request
  Future<bool> _testProxyConnection(ProxyChain chain) async {
    try {
      // Use the HttpClient with proxy configuration
      final client = HttpClient();
      client.findProxy = (uri) {
        return 'PROXY 127.0.0.1:$_localPort';
      };
      
      // Make a test request to a service that returns your IP
      final request = await client.getUrl(Uri.parse('https://api.ipify.org'));
      final response = await request.close();
      
      final responseBody = await response.transform(utf8.decoder).join();
      print('Proxy test response: $responseBody');
      
      // If we get a valid response, the proxy is working
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing proxy connection: $e');
      return false;
    }
  }
  
  /// Generate a 3proxy configuration file for the given chain
  Future<String?> _generateConfigFile(ProxyChain chain) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final configDir = Directory('${appDocDir.path}/config');
      
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      
      _configPath = '${configDir.path}/3proxy_${chain.id}.cfg';
      final configFile = File(_configPath!);
      
      final config = StringBuffer();
      config.writeln('daemon');
      config.writeln('pidfile ${configDir.path}/3proxy.pid');
      config.writeln('nscache 65536');
      config.writeln('timeouts 1 5 30 60 180 1800 15 60');
      config.writeln('log ${configDir.path}/3proxy.log D');
      
      // Set up the chain
      int currentPort = _localPort;
      
      // Start from the last proxy in the chain
      for (int i = chain.items.length - 1; i >= 0; i--) {
        final item = chain.items[i];
        final proxy = item.proxyServer;
        
        if (proxy == null) continue;
        
        final nextPort = (i == 0) ? _localPort : _localPort + i;
        
        if (proxy.proxyType.toLowerCase() == 'socks5') {
          config.write('auth none\n');
          
          // If authentication is required
          if (proxy.username != null && proxy.password != null) {
            config.write('auth strong\n');
            config.write('users ${proxy.username}:CL:${proxy.password}\n');
          }
          
          if (i == chain.items.length - 1) {
            // Last proxy in chain connects directly to the internet
            config.write('socks -p$nextPort -i127.0.0.1 -e${proxy.ipAddress}\n');
          } else {
            // This proxy forwards to the next one in the chain
            config.write('socks -p$nextPort -i127.0.0.1 -e127.0.0.1:${currentPort}\n');
          }
        }
        
        // Store the current port for the next iteration
        currentPort = nextPort;
      }
      
      await configFile.writeAsString(config.toString());
      return _configPath;
    } catch (e) {
      print('Error generating config file: $e');
      return null;
    }
  }
  
  /// Get information about the current system proxy settings
  Future<Map<String, String>> getSystemProxyInfo() async {
    try {
      final result = await Process.run('networksetup', ['-getwebproxy', 'Wi-Fi']);
      final socks = await Process.run('networksetup', ['-getsocksfirewallproxy', 'Wi-Fi']);
      
      return {
        'http': result.stdout.toString(),
        'socks': socks.stdout.toString(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  /// Set system-wide SOCKS proxy (requires macOS or appropriate platform)
  Future<bool> setSystemProxy(bool enable) async {
    try {
      if (enable) {
        await Process.run('networksetup', [
          '-setsocksfirewallproxy',
          'Wi-Fi',
          '127.0.0.1',
          '$_localPort'
        ]);
      } else {
        await Process.run('networksetup', [
          '-setsocksfirewallproxystate',
          'Wi-Fi',
          'off'
        ]);
      }
      return true;
    } catch (e) {
      print('Error setting system proxy: $e');
      return false;
    }
  }
  
  /// Fetch country information for a proxy server using its IP
  Future<Map<String, dynamic>> fetchProxyCountryInfo(String ipAddress) async {
    try {
      final response = await http.get(Uri.parse(
        'https://ipapi.co/$ipAddress/json/'
      ));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'country': data['country_name'] ?? 'Unknown',
          'country_code': data['country_code'] ?? 'XX',
          'city': data['city'] ?? 'Unknown',
          'region': data['region'] ?? 'Unknown',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      }
      
      return {
        'country': 'Unknown',
        'country_code': 'XX',
        'city': 'Unknown',
      };
    } catch (e) {
      print('Error fetching proxy country info: $e');
      return {
        'country': 'Unknown',
        'country_code': 'XX',
        'city': 'Unknown',
      };
    }
  }
  
  /// Check proxy latency by making a test connection
  Future<int> checkProxyLatency(ProxyServer proxy) async {
    try {
      final client = HttpClient();
      final stopwatch = Stopwatch()..start();
      
      // Set up the proxy
      client.findProxy = (uri) {
        return 'PROXY ${proxy.ipAddress}:${proxy.port}';
      };
      
      // Set a timeout
      client.connectionTimeout = const Duration(seconds: 5);
      
      try {
        // Try to connect to a reliable service
        final request = await client.getUrl(Uri.parse('https://www.google.com'));
        final response = await request.close();
        await response.drain(); // Drain the response
        
        stopwatch.stop();
        client.close();
        
        return stopwatch.elapsedMilliseconds;
      } catch (e) {
        client.close();
        return 9999; // Very high latency indicates failure
      }
    } catch (e) {
      return 9999;
    }
  }
  
  /// Enhance proxy information with country data and latency
  Future<ProxyServer> enhanceProxyInfo(ProxyServer proxy) async {
    // Fetch country information
    if (proxy.country == 'Unknown') {
      final countryInfo = await fetchProxyCountryInfo(proxy.ipAddress);
      
      // Update the proxy with country information
      proxy = proxy.copyWith(
        country: countryInfo['country'],
        city: countryInfo['city'],
      );
    }
    
    return proxy;
  }
  
  /// Batch enhance proxies with country information
  /// This will get country info for a batch of proxies more efficiently
  Future<List<ProxyServer>> enhanceProxiesInfo(List<ProxyServer> proxies, {int maxBatchSize = 5}) async {
    final enhancedProxies = <ProxyServer>[];
    
    // Process in batches to avoid too many concurrent requests
    for (int i = 0; i < proxies.length; i += maxBatchSize) {
      final endIndex = (i + maxBatchSize < proxies.length) ? i + maxBatchSize : proxies.length;
      final batch = proxies.sublist(i, endIndex);
      
      // Process batch in parallel
      final enhancedBatch = await Future.wait(
        batch.map((proxy) => enhanceProxyInfo(proxy))
      );
      
      enhancedProxies.addAll(enhancedBatch);
    }
    
    return enhancedProxies;
  }
} 