import '../../../../shared/domain/entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceRecordsUseCase {
  final AttendanceRepository _repository;

  GetAttendanceRecordsUseCase(this._repository);

  Future<List<AttendanceRecord>> call(String schoolId, DateTime date) async {
    return await _repository.getAttendanceRecords(schoolId, date);
  }
}
