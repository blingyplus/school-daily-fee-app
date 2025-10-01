import '../../../../shared/domain/entities/student_fee_config.dart';
import '../repositories/student_repository.dart';

class UpdateStudentFeeConfigUseCase {
  final StudentRepository repository;

  UpdateStudentFeeConfigUseCase(this.repository);

  Future<StudentFeeConfig> call(StudentFeeConfig config) async {
    return await repository.updateStudentFeeConfig(config);
  }
}
