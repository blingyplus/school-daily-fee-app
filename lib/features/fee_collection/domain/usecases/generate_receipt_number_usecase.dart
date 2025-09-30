import '../repositories/fee_collection_repository.dart';

class GenerateReceiptNumberUseCase {
  final FeeCollectionRepository _repository;

  GenerateReceiptNumberUseCase(this._repository);

  Future<String> call() async {
    return await _repository.generateReceiptNumber();
  }
}
