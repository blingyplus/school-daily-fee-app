import '../../../../shared/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class CreateStudentUseCase {
  final StudentRepository _repository;

  CreateStudentUseCase(this._repository);

  Future<Student> call({
    required String schoolId,
    required String classId,
    required String studentId,
    required String firstName,
    required String lastName,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? parentPhone,
    String? parentEmail,
    String? address,
  }) async {
    final now = DateTime.now();

    final student = Student(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      schoolId: schoolId,
      classId: classId,
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
      parentPhone: parentPhone,
      parentEmail: parentEmail,
      address: address,
      isActive: true,
      enrolledAt: now,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createStudent(student);
  }
}
