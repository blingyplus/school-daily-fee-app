import '../../../../shared/domain/entities/fee_collection.dart';
import '../repositories/fee_collection_repository.dart';

class GetFeeCollectionsUseCase {
  final FeeCollectionRepository _repository;

  GetFeeCollectionsUseCase(this._repository);

  Future<List<FeeCollection>> call(String schoolId, DateTime date) async {
    return await _repository.getFeeCollections(schoolId, date);
  }
}
