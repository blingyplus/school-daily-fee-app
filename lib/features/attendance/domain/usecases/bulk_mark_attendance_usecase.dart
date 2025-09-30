import '../../../../shared/domain/entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class BulkMarkAttendanceUseCase {
  final AttendanceRepository _repository;

  BulkMarkAttendanceUseCase(this._repository);

  Future<List<AttendanceRecord>> call({
    required String schoolId,
    required String classId,
    required String recordedBy,
    required DateTime attendanceDate,
    required List<String> studentIds,
    required AttendanceStatus status,
    String? notes,
  }) async {
    final records = <AttendanceRecord>[];

    for (final studentId in studentIds) {
      final record = await _repository.createAttendanceRecord(
        AttendanceRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$studentId',
          schoolId: schoolId,
          studentId: studentId,
          classId: classId,
          recordedBy: recordedBy,
          attendanceDate: attendanceDate,
          status: status,
          notes: notes,
          recordedAt: DateTime.now(),
          syncStatus: 'pending',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      records.add(record);
    }

    return records;
  }
}
