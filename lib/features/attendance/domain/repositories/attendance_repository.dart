import '../../../../shared/domain/entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceRecord>> getAttendanceRecords(
      String schoolId, DateTime date);
  Future<List<AttendanceRecord>> getAttendanceRecordsByClass(
      String classId, DateTime date);
  Future<AttendanceRecord?> getAttendanceRecord(
      String studentId, DateTime date);
  Future<List<AttendanceRecord>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate);
  Future<AttendanceRecord> createAttendanceRecord(AttendanceRecord record);
  Future<AttendanceRecord> updateAttendanceRecord(AttendanceRecord record);
  Future<void> deleteAttendanceRecord(String id);
  Future<List<AttendanceRecord>> getPendingSyncRecords();
}
