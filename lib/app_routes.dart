import 'package:flutter/material.dart';
import 'package:hape_vpn/presentation/screens/auth/login_screen.dart';
import 'package:hape_vpn/presentation/screens/auth/signup_screen.dart';
import 'package:hape_vpn/presentation/screens/home/home_screen.dart';
import 'package:hape_vpn/presentation/screens/proxy/proxy_chain_screen.dart';
import 'package:hape_vpn/presentation/screens/servers/server_list_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/account_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/app_settings_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/help_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/settings_screen.dart';
import 'package:hape_vpn/presentation/screens/settings/subscription_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String servers = '/servers';
  static const String settings = '/settings';
  static const String account = '/account';
  static const String subscription = '/subscription';
  static const String appSettings = '/app_settings';
  static const String help = '/help';
  static const String proxyChains = '/proxy_chains';
  
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    servers: (context) => const ServerListScreen(),
    settings: (context) => const SettingsScreen(),
    account: (context) => const AccountScreen(),
    subscription: (context) => const SubscriptionScreen(),
    appSettings: (context) => const AppSettingsScreen(),
    help: (context) => const HelpScreen(),
    proxyChains: (context) => const ProxyChainScreen(),
  };
} 