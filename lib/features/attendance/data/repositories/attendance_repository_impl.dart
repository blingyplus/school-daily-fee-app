import 'dart:async';
import '../../domain/repositories/attendance_repository.dart';
import '../../../../shared/domain/entities/attendance_record.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/attendance_remote_datasource.dart';
import '../models/attendance_record_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource _localDataSource;
  final AttendanceRemoteDataSource _remoteDataSource;

  AttendanceRepositoryImpl({
    required AttendanceLocalDataSource localDataSource,
    required AttendanceRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<List<AttendanceRecord>> getAttendanceRecords(
      String schoolId, DateTime date) async {
    try {
      final localRecords =
          await _localDataSource.getAttendanceRecords(schoolId, date);
      return localRecords.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get attendance records: $e');
    }
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceRecordsByClass(
      String classId, DateTime date) async {
    try {
      final localRecords =
          await _localDataSource.getAttendanceRecordsByClass(classId, date);
      return localRecords.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get attendance records by class: $e');
    }
  }

  @override
  Future<AttendanceRecord?> getAttendanceRecord(
      String studentId, DateTime date) async {
    try {
      final localRecord =
          await _localDataSource.getAttendanceRecord(studentId, date);
      return localRecord?.toEntity();
    } catch (e) {
      throw Exception('Failed to get attendance record: $e');
    }
  }

  @override
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate) async {
    try {
      final localRecords = await _localDataSource.getStudentAttendanceHistory(
          studentId, startDate, endDate);
      return localRecords.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get student attendance history: $e');
    }
  }

  @override
  Future<AttendanceRecord> createAttendanceRecord(
      AttendanceRecord record) async {
    try {
      final recordModel = AttendanceRecordModel.fromEntity(record);

      // Save to local database first
      await _localDataSource.createAttendanceRecord(recordModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return record;
    } catch (e) {
      throw Exception('Failed to create attendance record: $e');
    }
  }

  @override
  Future<AttendanceRecord> updateAttendanceRecord(
      AttendanceRecord record) async {
    try {
      final recordModel = AttendanceRecordModel.fromEntity(record);

      // Update local database
      await _localDataSource.updateAttendanceRecord(recordModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return record;
    } catch (e) {
      throw Exception('Failed to update attendance record: $e');
    }
  }

  @override
  Future<void> deleteAttendanceRecord(String id) async {
    try {
      // Delete from local database
      await _localDataSource.deleteAttendanceRecord(id);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }

  @override
  Future<List<AttendanceRecord>> getPendingSyncRecords() async {
    try {
      final localRecords = await _localDataSource.getPendingSyncRecords();
      return localRecords.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending sync records: $e');
    }
  }

  // Remote sync methods (for sync engine)
  Future<List<AttendanceRecord>> syncAttendanceRecordsFromRemote(
      String schoolId, DateTime date) async {
    try {
      final remoteRecords =
          await _remoteDataSource.getAttendanceRecords(schoolId, date);
      return remoteRecords.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to sync attendance records from remote: $e');
    }
  }

  Future<AttendanceRecord> syncCreateAttendanceRecordToRemote(
      AttendanceRecord record) async {
    try {
      final recordModel = AttendanceRecordModel.fromEntity(record);
      final remoteRecord =
          await _remoteDataSource.createAttendanceRecord(recordModel);
      return remoteRecord.toEntity();
    } catch (e) {
      throw Exception('Failed to sync create attendance record to remote: $e');
    }
  }

  Future<AttendanceRecord> syncUpdateAttendanceRecordToRemote(
      AttendanceRecord record) async {
    try {
      final recordModel = AttendanceRecordModel.fromEntity(record);
      final remoteRecord =
          await _remoteDataSource.updateAttendanceRecord(recordModel);
      return remoteRecord.toEntity();
    } catch (e) {
      throw Exception('Failed to sync update attendance record to remote: $e');
    }
  }

  Future<void> syncDeleteAttendanceRecordToRemote(String id) async {
    try {
      await _remoteDataSource.deleteAttendanceRecord(id);
    } catch (e) {
      throw Exception('Failed to sync delete attendance record to remote: $e');
    }
  }
}
