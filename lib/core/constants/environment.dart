enum EnvironmentType { mock, development, production }

class Environment {
  // Environment Configuration
  static const EnvironmentType currentEnvironment = EnvironmentType.development;

  // Database
  static const String dbName = 'school_fee_app.db';
  static const int dbVersion = 1;

  // Supabase Configuration
  static String get supabaseUrl {
    switch (currentEnvironment) {
      case EnvironmentType.mock:
        return 'https://dmvfqhaotzackosvboqs.supabase.co'; // Use same for mock testing
      case EnvironmentType.development:
        return 'https://dmvfqhaotzackosvboqs.supabase.co';
      case EnvironmentType.production:
        return 'https://dmvfqhaotzackosvboqs.supabase.co';
    }
  }

  static String get supabaseAnonKey {
    switch (currentEnvironment) {
      case EnvironmentType.mock:
        return supabaseToken; // Use same for mock testing
      case EnvironmentType.development:
        return supabaseToken;
      case EnvironmentType.production:
        return supabaseToken;
    }
  }

  static const int apiTimeout = 30000; // 30 seconds

  // App Configuration
  static const String appVersion = '1.0.0';
  static const String appName = 'Skuupay';

  // Environment-specific flags
  static bool get useMockData => currentEnvironment == EnvironmentType.mock;
  static bool get enableLogging =>
      currentEnvironment != EnvironmentType.production;
  static bool get enableCrashlytics =>
      currentEnvironment == EnvironmentType.production;
  static bool get useSupabase => currentEnvironment != EnvironmentType.mock;

  // Mock Data Configuration
  static const String mockDataPath = 'assets/mock_data/';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;

  static const String supabaseToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRtdmZxaGFvdHphY2tvc3Zib3FzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNTIxNjEsImV4cCI6MjA3NDcyODE2MX0.MHFRSzIabxExQfaK_KXeYGfiw6d58plRCjbiFL08atE';
}
