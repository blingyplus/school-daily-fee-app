import '../repositories/student_repository.dart';

class DeleteStudentUseCase {
  final StudentRepository _repository;

  DeleteStudentUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteStudent(id);
  }
}
