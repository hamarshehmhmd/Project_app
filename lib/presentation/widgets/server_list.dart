import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';
import 'package:hape_vpn/presentation/widgets/server_card.dart';

class ServerList extends ConsumerWidget {
  final List<VpnServer> servers;
  final String title;
  final bool showTitle;
  final ScrollPhysics? physics;
  final EdgeInsets padding;
  final int? maxItems;
  
  const ServerList({
    super.key,
    required this.servers,
    this.title = 'Servers',
    this.showTitle = true,
    this.physics,
    this.padding = const EdgeInsets.all(0),
    this.maxItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnProvider);
    final vpnNotifier = ref.read(vpnProvider.notifier);
    
    // Optional limit to the number of servers shown
    final displayedServers = maxItems != null && maxItems! < servers.length
        ? servers.sublist(0, maxItems)
        : servers;
    
    if (displayedServers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No servers available',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }
    
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          
          ListView.builder(
            shrinkWrap: true,
            physics: physics ?? const NeverScrollableScrollPhysics(),
            itemCount: displayedServers.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final server = displayedServers[index];
              final isConnected = vpnState.currentServer?.id == server.id && 
                  vpnState.status == VpnStatus.connected;
              
              return ServerCard(
                server: server,
                isConnected: isConnected,
                onTap: () async {
                  // If not connected to this server, connect to it
                  if (!isConnected) {
                    await vpnNotifier.connectToServer(server);
                  } else {
                    // If already connected to this server, disconnect
                    await vpnNotifier.disconnect();
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
} 