import '../../../../shared/domain/entities/student_fee_config.dart';
import '../repositories/student_repository.dart';

class GetStudentFeeConfigUseCase {
  final StudentRepository repository;

  GetStudentFeeConfigUseCase(this.repository);

  Future<StudentFeeConfig?> call(String studentId) async {
    return await repository.getStudentFeeConfig(studentId);
  }
}
