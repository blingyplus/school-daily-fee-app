import '../../../../shared/domain/entities/fee_collection.dart';
import '../repositories/fee_collection_repository.dart';

class CollectFeeUseCase {
  final FeeCollectionRepository _repository;

  CollectFeeUseCase(this._repository);

  Future<FeeCollection> call({
    required String schoolId,
    required String studentId,
    required String collectedBy,
    required FeeType feeType,
    required double amountPaid,
    required DateTime paymentDate,
    required DateTime coverageStartDate,
    required DateTime coverageEndDate,
    required PaymentMethod paymentMethod,
    required String receiptNumber,
    String? notes,
  }) async {
    final now = DateTime.now();

    final collection = FeeCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      schoolId: schoolId,
      studentId: studentId,
      collectedBy: collectedBy,
      feeType: feeType,
      amountPaid: amountPaid,
      paymentDate: paymentDate,
      coverageStartDate: coverageStartDate,
      coverageEndDate: coverageEndDate,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      notes: notes,
      collectedAt: now,
      syncStatus: 'pending',
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createFeeCollection(collection);
  }
}
