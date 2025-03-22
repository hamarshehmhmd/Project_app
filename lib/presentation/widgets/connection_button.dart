import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/infrastructure/vpn/vpn_service.dart';
import 'package:hape_vpn/presentation/providers/providers.dart';

class ConnectionButton extends ConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnProvider);
    final theme = Theme.of(context);
    
    // Button size
    const double buttonSize = 180;
    
    // Color based on connection state
    final buttonColor = switch (vpnState.status) {
      VpnStatus.connected => theme.colorScheme.primary,
      VpnStatus.connecting => Colors.amber,
      VpnStatus.disconnecting => Colors.orange,
      VpnStatus.error => Colors.red,
      _ => Colors.grey,
    };
    
    // Icon based on connection state
    final icon = switch (vpnState.status) {
      VpnStatus.connected => Icons.power_settings_new,
      VpnStatus.connecting => Icons.hourglass_top,
      VpnStatus.disconnecting => Icons.hourglass_bottom,
      VpnStatus.error => Icons.error,
      _ => Icons.power_settings_new,
    };
    
    // Button text
    final buttonText = switch (vpnState.status) {
      VpnStatus.connected => 'Disconnect',
      VpnStatus.connecting => 'Connecting',
      VpnStatus.disconnecting => 'Disconnecting',
      VpnStatus.error => 'Error',
      _ => 'Connect',
    };
    
    return GestureDetector(
      onTap: () {
        if (vpnState.status == VpnStatus.connecting || 
            vpnState.status == VpnStatus.disconnecting) {
          return;
        }
        
        if (vpnState.status == VpnStatus.connected) {
          ref.read(vpnProvider.notifier).disconnect();
        } else if (vpnState.status == VpnStatus.disconnected) {
          // If there is a current server, reconnect to it
          // Otherwise, prompt user to select a server
          if (vpnState.currentServer != null) {
            ref.read(vpnProvider.notifier).connect(vpnState.currentServer!);
          } else if (vpnState.recommendedServers.isNotEmpty) {
            ref.read(vpnProvider.notifier).connect(vpnState.recommendedServers.first);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a server first'),
              ),
            );
          }
        }
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: buttonColor,
            width: 4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: buttonColor,
            ),
            const SizedBox(height: 8),
            Text(
              buttonText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: buttonColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 