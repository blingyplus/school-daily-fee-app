class Environment {
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-api-url.com/api/v1',
  );

  static const String _dbName = String.fromEnvironment(
    'DB_NAME',
    defaultValue: 'school_fee_app.db',
  );

  static const int _dbVersion = int.fromEnvironment(
    'DB_VERSION',
    defaultValue: 1,
  );

  static const int _apiTimeout = int.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: 30000,
  );

  static const int _syncIntervalMinutes = int.fromEnvironment(
    'SYNC_INTERVAL_MINUTES',
    defaultValue: 15,
  );

  static const int _maxRetryAttempts = int.fromEnvironment(
    'MAX_RETRY_ATTEMPTS',
    defaultValue: 3,
  );

  static const int _maxFileSizeMB = int.fromEnvironment(
    'MAX_FILE_SIZE_MB',
    defaultValue: 10,
  );

  // Getters
  static String get environment => _environment;
  static String get supabaseUrl => _supabaseUrl;
  static String get supabaseAnonKey => _supabaseAnonKey;
  static String get apiBaseUrl => _apiBaseUrl;
  static String get dbName => _dbName;
  static int get dbVersion => _dbVersion;
  static int get apiTimeout => _apiTimeout;
  static int get syncIntervalMinutes => _syncIntervalMinutes;
  static int get maxRetryAttempts => _maxRetryAttempts;
  static int get maxFileSizeMB => _maxFileSizeMB;

  // Environment checks
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';

  // App Configuration
  static const String appName = 'School Daily Fee App';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@schoolfeeapp.com';

  // File Configuration
  static const List<String> allowedFileTypes = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'xlsx',
    'csv',
  ];

  // Security
  static const String encryptionKey = 'your_32_character_encryption_key_here';
  static const String jwtSecret = 'your_jwt_secret_here';
}
