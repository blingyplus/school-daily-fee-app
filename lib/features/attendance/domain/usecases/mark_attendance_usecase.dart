import 'package:uuid/uuid.dart';
import '../../../../shared/domain/entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendanceUseCase {
  final AttendanceRepository _repository;

  MarkAttendanceUseCase(this._repository);

  Future<AttendanceRecord> call({
    required String schoolId,
    required String studentId,
    required String classId,
    required String recordedBy,
    required DateTime attendanceDate,
    required AttendanceStatus status,
    String? notes,
  }) async {
    final now = DateTime.now();
    final uuid = const Uuid();

    final record = AttendanceRecord(
      id: uuid.v4(),
      schoolId: schoolId,
      studentId: studentId,
      classId: classId,
      recordedBy: recordedBy,
      attendanceDate: attendanceDate,
      status: status,
      notes: notes,
      recordedAt: now,
      syncStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createAttendanceRecord(record);
  }
}
