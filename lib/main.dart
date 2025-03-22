import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hape_vpn/app_routes.dart';
import 'package:hape_vpn/infrastructure/supabase/supabase_config.dart';
import 'package:hape_vpn/presentation/screens/auth/login_screen.dart';
import 'package:hape_vpn/presentation/screens/home/home_screen.dart';
import 'package:hape_vpn/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(
    const ProviderScope(
      child: HapeVpnApp(),
    ),
  );
}

class HapeVpnApp extends ConsumerWidget {
  const HapeVpnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'Hape VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          secondary: const Color(0xFF00BFA5),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          secondary: const Color(0xFF00BFA5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: authState.status == AuthStatus.authenticated
          ? AppRoutes.home
          : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
