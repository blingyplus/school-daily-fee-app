import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/environment.dart';

class SupabaseClientConfig {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    _client ??= Supabase.instance.client;
    return _client!;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Environment.supabaseUrl,
      anonKey: Environment.supabaseAnonKey,
      debug: Environment.enableLogging,
    );
  }

  static void dispose() {
    _client = null;
  }
}
