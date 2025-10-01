class AppConstants {
  // App Information
  static const String appName = 'Skuupay';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A superfast mobile app to allow schools to manage canteen and bus fees collections easily';

  // Database
  static const String databaseName = 'school_fee_app.db';
  static const int databaseVersion = 1;

  // API
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int syncIntervalMinutes = 15;

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentTypes = ['pdf', 'xlsx', 'csv'];

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd/MM/yyyy';
  static const String displayDateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₵';

  // Sync Status
  static const String syncStatusPending = 'pending';
  static const String syncStatusSyncing = 'syncing';
  static const String syncStatusSynced = 'synced';
  static const String syncStatusFailed = 'failed';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleStaff = 'staff';

  // Fee Types
  static const String feeTypeCanteen = 'canteen';
  static const String feeTypeTransport = 'transport';

  // Attendance Status
  static const String attendancePresent = 'present';
  static const String attendanceAbsent = 'absent';
  static const String attendanceLate = 'late';

  // Payment Methods
  static const String paymentMethodCash = 'cash';
  static const String paymentMethodCard = 'card';
  static const String paymentMethodUPI = 'upi';
  static const String paymentMethodCheque = 'cheque';

  // Scholarship Types
  static const String scholarshipTypePercentage = 'percentage';
  static const String scholarshipTypeFixed = 'fixed';
  static const String scholarshipTypeFull = 'full';

  // Error Messages
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorServerError = 'Server error occurred';
  static const String errorUnknown = 'An unknown error occurred';
  static const String errorInvalidCredentials = 'Invalid credentials';
  static const String errorSessionExpired = 'Session expired';

  // Success Messages
  static const String successDataSynced = 'Data synced successfully';
  static const String successDataSaved = 'Data saved successfully';
  static const String successPaymentRecorded = 'Payment recorded successfully';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Storage Keys
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyActiveSchoolId = 'active_school_id';
  static const String keyLastSyncTime = 'last_sync_time';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
}
