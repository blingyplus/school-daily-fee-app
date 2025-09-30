import '../../../../shared/domain/entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetClassAttendanceUseCase {
  final AttendanceRepository _repository;

  GetClassAttendanceUseCase(this._repository);

  Future<List<AttendanceRecord>> call(String classId, DateTime date) async {
    return await _repository.getAttendanceRecordsByClass(classId, date);
  }
}
