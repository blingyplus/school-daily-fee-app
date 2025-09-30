import '../../../../shared/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class UpdateStudentUseCase {
  final StudentRepository _repository;

  UpdateStudentUseCase(this._repository);

  Future<Student> call(Student student) async {
    final updatedStudent = student.copyWith(
      updatedAt: DateTime.now(),
    );

    return await _repository.updateStudent(updatedStudent);
  }
}
