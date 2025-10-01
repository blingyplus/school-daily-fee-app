import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../models/student_model.dart';
import '../models/student_fee_config_model.dart';

abstract class StudentLocalDataSource {
  Future<List<StudentModel>> getStudents(String schoolId);
  Future<StudentModel?> getStudentById(String id);
  Future<StudentModel?> getStudentByStudentId(
      String schoolId, String studentId);
  Future<List<StudentModel>> searchStudents(String schoolId, String query);
  Future<List<StudentModel>> getStudentsByClass(String classId);
  Future<String> createStudent(StudentModel student);
  Future<void> updateStudent(StudentModel student);
  Future<void> deleteStudent(String id);
  Future<void> createStudentFeeConfig(StudentFeeConfigModel config);
  Future<StudentFeeConfigModel?> getStudentFeeConfig(String studentId);
  Future<void> updateStudentFeeConfig(StudentFeeConfigModel config);
}

class StudentLocalDataSourceImpl implements StudentLocalDataSource {
  final Database _database;

  StudentLocalDataSourceImpl(this._database);

  @override
  Future<List<StudentModel>> getStudents(String schoolId) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'school_id = ? AND is_active = ?',
      whereArgs: [schoolId, 1],
      orderBy: 'first_name ASC, last_name ASC',
    );

    return maps.map((map) => StudentModel.fromMap(map)).toList();
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<StudentModel?> getStudentByStudentId(
      String schoolId, String studentId) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'school_id = ? AND student_id = ?',
      whereArgs: [schoolId, studentId],
    );

    if (maps.isNotEmpty) {
      return StudentModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<StudentModel>> searchStudents(
      String schoolId, String query) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where:
          'school_id = ? AND is_active = ? AND (first_name LIKE ? OR last_name LIKE ? OR student_id LIKE ?)',
      whereArgs: [schoolId, 1, '%$query%', '%$query%', '%$query%'],
      orderBy: 'first_name ASC, last_name ASC',
    );

    return maps.map((map) => StudentModel.fromMap(map)).toList();
  }

  @override
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudents,
      where: 'class_id = ? AND is_active = ?',
      whereArgs: [classId, 1],
      orderBy: 'first_name ASC, last_name ASC',
    );

    return maps.map((map) => StudentModel.fromMap(map)).toList();
  }

  @override
  Future<String> createStudent(StudentModel student) async {
    final db = _database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final studentMap = student.toMap();
    studentMap['created_at'] = now;
    studentMap['updated_at'] = now;
    studentMap['enrolled_at'] = now;

    await db.insert(DatabaseHelper.tableStudents, studentMap);

    // Create default fee config for the student
    final feeConfig = StudentFeeConfigModel(
      id: const Uuid().v4(),
      studentId: student.id,
      canteenDailyFee: 9.0, // Default canteen fee
      transportDailyFee: 0.0,
      canteenEnabled: true,
      transportEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createStudentFeeConfig(feeConfig);

    return student.id;
  }

  @override
  Future<void> updateStudent(StudentModel student) async {
    final db = _database;
    final studentMap = student.toMap();
    studentMap['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      DatabaseHelper.tableStudents,
      studentMap,
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  @override
  Future<void> deleteStudent(String id) async {
    final db = _database;

    // Soft delete - mark as inactive
    await db.update(
      DatabaseHelper.tableStudents,
      {
        'is_active': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> createStudentFeeConfig(StudentFeeConfigModel config) async {
    final db = _database;
    final configMap = config.toMap();

    await db.insert(DatabaseHelper.tableStudentFeeConfig, configMap);
  }

  @override
  Future<StudentFeeConfigModel?> getStudentFeeConfig(String studentId) async {
    final db = _database;
    final maps = await db.query(
      DatabaseHelper.tableStudentFeeConfig,
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    if (maps.isNotEmpty) {
      return StudentFeeConfigModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> updateStudentFeeConfig(StudentFeeConfigModel config) async {
    final db = _database;
    final configMap = config.toMap();
    configMap['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      DatabaseHelper.tableStudentFeeConfig,
      configMap,
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }
}
