import '../../../../shared/domain/entities/fee_collection.dart';
import '../repositories/fee_collection_repository.dart';

class GetStudentFeeHistoryUseCase {
  final FeeCollectionRepository _repository;

  GetStudentFeeHistoryUseCase(this._repository);

  Future<List<FeeCollection>> call(
      String studentId, DateTime startDate, DateTime endDate) async {
    return await _repository.getFeeCollectionsByStudent(
        studentId, startDate, endDate);
  }
}
