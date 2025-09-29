enum EnvironmentType { mock, development, production }

class Environment {
  // Environment Configuration
  static const EnvironmentType currentEnvironment = EnvironmentType.mock;

  // Database
  static const String dbName = 'school_fee_app.db';
  static const int dbVersion = 1;

  // API Configuration
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case EnvironmentType.mock:
        return 'http://localhost:3000/v1'; // Mock server
      case EnvironmentType.development:
        return 'https://dev-api.schoolfeeapp.com/v1';
      case EnvironmentType.production:
        return 'https://api.schoolfeeapp.com/v1';
    }
  }

  static const int apiTimeout = 30000; // 30 seconds

  // App Configuration
  static const String appVersion = '1.0.0';
  static const String appName = 'School Daily Fee App';

  // Environment-specific flags
  static bool get useMockData => currentEnvironment == EnvironmentType.mock;
  static bool get enableLogging =>
      currentEnvironment != EnvironmentType.production;
  static bool get enableCrashlytics =>
      currentEnvironment == EnvironmentType.production;

  // Mock Data Configuration
  static const String mockDataPath = 'assets/mock_data/';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = false;
  static const bool enableAnalytics = false;
}
