import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://adzvvfsffhfmicinhloy.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkenZ2ZnNmZmhmbWljaW5obG95Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI1Njc4MTMsImV4cCI6MjA1ODE0MzgxM30.VcEdOVreYsLHmZ1ooKo4zCWIp1aWTGByM4rbKDBUAAI';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
  }
} 