import 'dart:async';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../models/attendance_record_model.dart';

abstract class AttendanceLocalDataSource {
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
      String schoolId, DateTime date);
  Future<List<AttendanceRecordModel>> getAttendanceRecordsByClass(
      String classId, DateTime date);
  Future<AttendanceRecordModel?> getAttendanceRecord(
      String studentId, DateTime date);
  Future<AttendanceRecordModel?> getAttendanceRecordById(String id);
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate);
  Future<String> createAttendanceRecord(AttendanceRecordModel record);
  Future<void> updateAttendanceRecord(AttendanceRecordModel record);
  Future<void> deleteAttendanceRecord(String id);
  Future<List<AttendanceRecordModel>> getPendingSyncRecords();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final DatabaseHelper _databaseHelper;

  AttendanceLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
      String schoolId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'school_id = ? AND attendance_date >= ? AND attendance_date <= ?',
      whereArgs: [schoolId, startOfDay, endOfDay],
      orderBy: 'recorded_at DESC',
    );

    return maps.map((map) => AttendanceRecordModel.fromMap(map)).toList();
  }

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecordsByClass(
      String classId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'class_id = ? AND attendance_date >= ? AND attendance_date <= ?',
      whereArgs: [classId, startOfDay, endOfDay],
      orderBy: 'recorded_at DESC',
    );

    return maps.map((map) => AttendanceRecordModel.fromMap(map)).toList();
  }

  @override
  Future<AttendanceRecordModel?> getAttendanceRecord(
      String studentId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'student_id = ? AND attendance_date >= ? AND attendance_date <= ?',
      whereArgs: [studentId, startOfDay, endOfDay],
    );

    if (maps.isNotEmpty) {
      return AttendanceRecordModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'student_id = ? AND attendance_date >= ? AND attendance_date <= ?',
      whereArgs: [studentId, startTimestamp, endTimestamp],
      orderBy: 'attendance_date DESC',
    );

    return maps.map((map) => AttendanceRecordModel.fromMap(map)).toList();
  }

  @override
  Future<AttendanceRecordModel?> getAttendanceRecordById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AttendanceRecordModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<String> createAttendanceRecord(AttendanceRecordModel record) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final recordMap = record.toMap();
    recordMap['created_at'] = now;
    recordMap['updated_at'] = now;
    recordMap['recorded_at'] = now;

    await db.insert(DatabaseHelper.tableAttendanceRecords, recordMap);
    return record.id;
  }

  @override
  Future<void> updateAttendanceRecord(AttendanceRecordModel record) async {
    final db = await _databaseHelper.database;
    final recordMap = record.toMap();
    recordMap['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      DatabaseHelper.tableAttendanceRecords,
      recordMap,
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  @override
  Future<void> deleteAttendanceRecord(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableAttendanceRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<AttendanceRecordModel>> getPendingSyncRecords() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableAttendanceRecords,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => AttendanceRecordModel.fromMap(map)).toList();
  }
}
