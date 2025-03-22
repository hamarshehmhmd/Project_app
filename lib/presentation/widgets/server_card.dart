import 'package:flutter/material.dart';
import 'package:hape_vpn/domain/models/vpn_server.dart';

class ServerCard extends StatelessWidget {
  final VpnServer server;
  final bool isConnected;
  final VoidCallback onTap;
  
  const ServerCard({
    super.key,
    required this.server,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Color based on whether the server is connected
    final cardColor = isConnected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    
    // Text color
    final textColor = isConnected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Server icon with country flag
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    server.country.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Server details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.serverName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${server.country}${server.city != null ? ', ${server.city}' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Server status indicators
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (server.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 14,
                        color: textColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(100 - server.loadPercentage).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // Connected indicator
              if (isConnected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 