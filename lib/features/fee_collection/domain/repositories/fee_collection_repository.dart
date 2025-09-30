import '../../../../shared/domain/entities/fee_collection.dart';

abstract class FeeCollectionRepository {
  Future<List<FeeCollection>> getFeeCollections(String schoolId, DateTime date);
  Future<List<FeeCollection>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate);
  Future<List<FeeCollection>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date);
  Future<FeeCollection?> getFeeCollectionById(String id);
  Future<FeeCollection> createFeeCollection(FeeCollection collection);
  Future<FeeCollection> updateFeeCollection(FeeCollection collection);
  Future<void> deleteFeeCollection(String id);
  Future<List<FeeCollection>> getPendingSyncRecords();
  Future<String> generateReceiptNumber();
}
