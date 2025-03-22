import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/presentation/providers/vpn_provider.dart';

class StatusCard extends ConsumerWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnProvider);
    final theme = Theme.of(context);
    
    // Determine colors and text based on VPN status
    late final Color statusColor;
    late final String statusText;
    late final IconData statusIcon;
    
    switch (vpnState.status) {
      case VpnStatus.connected:
        statusColor = Colors.green;
        statusText = 'Connected';
        statusIcon = Icons.shield;
        break;
      case VpnStatus.connecting:
        statusColor = Colors.orange;
        statusText = 'Connecting';
        statusIcon = Icons.pending;
        break;
      case VpnStatus.disconnecting:
        statusColor = Colors.orange;
        statusText = 'Disconnecting';
        statusIcon = Icons.pending;
        break;
      case VpnStatus.error:
        statusColor = Colors.red;
        statusText = 'Connection Error';
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Not Connected';
        statusIcon = Icons.shield_outlined;
    }
    
    // Server information
    final serverInfo = vpnState.currentServer != null
        ? '${vpnState.currentServer!.country} - ${vpnState.currentServer!.serverName}'
        : 'No server selected';
    
    // IP address information
    final ipInfo = vpnState.status == VpnStatus.connected && vpnState.virtualIp != null
        ? 'Your IP: ${vpnState.virtualIp}'
        : vpnState.status == VpnStatus.disconnected && vpnState.realIp != null
            ? 'Your IP: ${vpnState.realIp}'
            : 'IP address: Loading...';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      serverInfo,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.public,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  ipInfo,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (vpnState.status == VpnStatus.connected && vpnState.connectionTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Connected for: ${_formatDuration(DateTime.now().difference(vpnState.connectionTime!))}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Helper method to format duration in a readable format
  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
} 