import '../../../../shared/domain/entities/fee_collection.dart';
import '../repositories/fee_collection_repository.dart';

class CheckStudentPaymentStatusUseCase {
  final FeeCollectionRepository repository;

  CheckStudentPaymentStatusUseCase(this.repository);

  /// Checks if a student has paid for a specific date and fee type
  /// Returns true if the date falls within any payment coverage period
  Future<bool> call({
    required String studentId,
    required DateTime date,
    required FeeType feeType,
  }) async {
    // Get all fee collections for the student around this date
    final startDate =
        date.subtract(const Duration(days: 60)); // Look back 2 months
    final endDate = date.add(const Duration(days: 60)); // Look ahead 2 months

    final collections = await repository.getFeeCollectionsByStudent(
      studentId,
      startDate,
      endDate,
    );

    // Check if any collection covers this date for this fee type
    for (final collection in collections) {
      if (collection.feeType == feeType) {
        final coverageStart = DateTime(
          collection.coverageStartDate.year,
          collection.coverageStartDate.month,
          collection.coverageStartDate.day,
        );
        final coverageEnd = DateTime(
          collection.coverageEndDate.year,
          collection.coverageEndDate.month,
          collection.coverageEndDate.day,
          23,
          59,
          59,
        );
        final checkDate = DateTime(date.year, date.month, date.day);

        if ((checkDate.isAfter(coverageStart) ||
                checkDate.isAtSameMomentAs(coverageStart)) &&
            (checkDate.isBefore(coverageEnd) ||
                checkDate.isAtSameMomentAs(coverageEnd))) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get payment status for all fee types
  Future<Map<FeeType, bool>> getStudentPaymentStatus({
    required String studentId,
    required DateTime date,
  }) async {
    final result = <FeeType, bool>{};

    for (final feeType in FeeType.values) {
      result[feeType] = await call(
        studentId: studentId,
        date: date,
        feeType: feeType,
      );
    }

    return result;
  }
}
