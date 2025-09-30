import '../../../../shared/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class GetStudentsUseCase {
  final StudentRepository _repository;

  GetStudentsUseCase(this._repository);

  Future<List<Student>> call(String schoolId) async {
    return await _repository.getStudents(schoolId);
  }
}
