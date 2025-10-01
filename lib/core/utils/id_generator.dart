import 'package:sqflite/sqflite.dart';
import '../di/injection.dart';
import '../../shared/data/datasources/local/database_helper.dart';

/// Utility class for generating unique IDs for students and employees.
/// Format: YEAR-SCHOOLCODE-SEQUENTIALNUMBER
/// Example: 2025-ABC-001, 2025-ABC-002
class IdGenerator {
  /// Generates a unique student ID for the given school
  /// Format: YEAR-SCHOOLCODE-SEQUENTIALNUMBER
  /// Example: 2025-ABC-001
  static Future<String> generateStudentId({
    required String schoolId,
    required String schoolCode,
  }) async {
    return _generateId(
      schoolId: schoolId,
      schoolCode: schoolCode,
      entityType: 'student',
    );
  }

  /// Generates a unique employee ID for the given school
  /// Format: YEAR-SCHOOLCODE-SEQUENTIALNUMBER
  /// Example: 2025-ABC-001
  static Future<String> generateEmployeeId({
    required String schoolId,
    required String schoolCode,
  }) async {
    return _generateId(
      schoolId: schoolId,
      schoolCode: schoolCode,
      entityType: 'employee',
    );
  }

  /// Internal method to generate IDs
  static Future<String> _generateId({
    required String schoolId,
    required String schoolCode,
    required String entityType,
  }) async {
    try {
      final database = getIt<Database>();
      final year = DateTime.now().year;
      final prefix = '$year-${schoolCode.toUpperCase()}';

      // Get the highest sequential number for this school and entity type
      int nextSequence = 1;

      if (entityType == 'student') {
        // Query students table for the highest sequence number
        final students = await database.query(
          DatabaseHelper.tableStudents,
          columns: ['student_id'],
          where: 'school_id = ? AND student_id LIKE ?',
          whereArgs: [schoolId, '$prefix-%'],
          orderBy: 'student_id DESC',
          limit: 1,
        );

        if (students.isNotEmpty) {
          final lastId = students.first['student_id'] as String;
          nextSequence = _extractSequenceNumber(lastId) + 1;
        }
      } else if (entityType == 'employee') {
        // Query teachers table for the highest sequence number
        final teachers = await database.query(
          DatabaseHelper.tableTeachers,
          columns: ['employee_id'],
          where: 'employee_id LIKE ?',
          whereArgs: ['$prefix-%'],
          orderBy: 'employee_id DESC',
          limit: 1,
        );

        if (teachers.isNotEmpty && teachers.first['employee_id'] != null) {
          final lastId = teachers.first['employee_id'] as String;
          nextSequence = _extractSequenceNumber(lastId) + 1;
        }
      }

      // Format the sequence number with leading zeros (3 digits)
      final sequenceStr = nextSequence.toString().padLeft(3, '0');

      return '$prefix-$sequenceStr';
    } catch (e) {
      print('❌ Error generating ID: $e');
      // Fallback to simple timestamp-based ID if database query fails
      final year = DateTime.now().year;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '$year-${schoolCode.toUpperCase()}-$timestamp';
    }
  }

  /// Extracts the sequence number from an ID
  /// Example: "2025-ABC-001" -> 1
  static int _extractSequenceNumber(String id) {
    try {
      final parts = id.split('-');
      if (parts.length >= 3) {
        return int.parse(parts[2]);
      }
    } catch (e) {
      print('⚠️ Error extracting sequence number from ID: $id');
    }
    return 0;
  }

  /// Validates if an ID follows the correct format
  /// Format: YEAR-SCHOOLCODE-SEQUENTIALNUMBER
  static bool isValidId(String id) {
    final pattern = RegExp(r'^\d{4}-[A-Z0-9]+-\d{3,}$');
    return pattern.hasMatch(id);
  }
}
