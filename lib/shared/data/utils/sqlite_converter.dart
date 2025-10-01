/// Utility class for converting SQLite data to proper Dart types
///
/// SQLite can return data in different formats (strings, integers, etc.)
/// This utility provides safe conversion methods that handle various formats.
class SqliteConverter {
  /// Safely convert a dynamic value to int
  ///
  /// Handles:
  /// - int values directly
  /// - String numbers (e.g., "123")
  /// - ISO 8601 timestamp strings (e.g., "2025-09-30T18:35:22.254+00:00")
  static int safeInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      // Check if it's a timestamp string
      if (value.contains('T') && value.contains(':')) {
        try {
          return DateTime.parse(value).millisecondsSinceEpoch;
        } catch (e) {
          // If parsing fails, try regular int parsing
          return int.parse(value);
        }
      }
      return int.parse(value);
    }
    throw Exception('Cannot convert $value to int');
  }

  /// Safely convert a dynamic value to int?, returning null for null values
  static int? safeIntNullable(dynamic value) {
    if (value == null) return null;
    return safeInt(value);
  }

  /// Safely convert a dynamic value to bool
  ///
  /// Handles:
  /// - bool values directly
  /// - int values (1 = true, 0 = false)
  /// - String values ("1", "true" = true; "0", "false" = false)
  static bool safeBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      return lowerValue == '1' || lowerValue == 'true';
    }
    throw Exception('Cannot convert $value to bool');
  }

  /// Safely convert a dynamic value to String
  ///
  /// Handles:
  /// - String values directly
  /// - Any other type by calling toString()
  /// - null values by returning empty string or provided default
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely convert a dynamic value to String?, returning null for null values
  static String? safeStringNullable(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Safely convert a dynamic value to double
  ///
  /// Handles:
  /// - double values directly
  /// - int values (converted to double)
  /// - String numbers (e.g., "123.45")
  static double safeDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw Exception('Cannot convert $value to double');
  }

  /// Safely convert a dynamic value to double?, returning null for null values
  static double? safeDoubleNullable(dynamic value) {
    if (value == null) return null;
    return safeDouble(value);
  }

  /// Safely convert a dynamic value to DateTime
  ///
  /// Handles:
  /// - DateTime values directly
  /// - int values (milliseconds since epoch)
  /// - String values (ISO 8601 format)
  static DateTime safeDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      // Try parsing as ISO 8601 first
      try {
        return DateTime.parse(value);
      } catch (e) {
        // If that fails, try parsing as int string
        return DateTime.fromMillisecondsSinceEpoch(int.parse(value));
      }
    }
    throw Exception('Cannot convert $value to DateTime');
  }

  /// Safely convert a dynamic value to DateTime?, returning null for null values
  static DateTime? safeDateTimeNullable(dynamic value) {
    if (value == null) return null;
    return safeDateTime(value);
  }
}
