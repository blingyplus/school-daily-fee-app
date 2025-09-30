import '../../../../shared/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class SearchStudentsUseCase {
  final StudentRepository _repository;

  SearchStudentsUseCase(this._repository);

  Future<List<Student>> call(String schoolId, String query) async {
    if (query.trim().isEmpty) {
      return await _repository.getStudents(schoolId);
    }
    return await _repository.searchStudents(schoolId, query.trim());
  }
}
