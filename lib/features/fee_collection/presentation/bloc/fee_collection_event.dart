import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

abstract class FeeCollectionEvent extends Equatable {
  const FeeCollectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeeCollections extends FeeCollectionEvent {
  final String schoolId;
  final DateTime date;

  const LoadFeeCollections(this.schoolId, this.date);

  @override
  List<Object?> get props => [schoolId, date];
}

class LoadStudentFeeHistory extends FeeCollectionEvent {
  final String studentId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadStudentFeeHistory(this.studentId, this.startDate, this.endDate);

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}

class CollectFee extends FeeCollectionEvent {
  final String schoolId;
  final String studentId;
  final String collectedBy;
  final FeeType feeType;
  final double amountPaid;
  final DateTime paymentDate;
  final DateTime coverageStartDate;
  final DateTime coverageEndDate;
  final PaymentMethod paymentMethod;
  final String receiptNumber;
  final String? notes;

  const CollectFee({
    required this.schoolId,
    required this.studentId,
    required this.collectedBy,
    required this.feeType,
    required this.amountPaid,
    required this.paymentDate,
    required this.coverageStartDate,
    required this.coverageEndDate,
    required this.paymentMethod,
    required this.receiptNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [
        schoolId,
        studentId,
        collectedBy,
        feeType,
        amountPaid,
        paymentDate,
        coverageStartDate,
        coverageEndDate,
        paymentMethod,
        receiptNumber,
        notes,
      ];
}

class UpdateFeeCollection extends FeeCollectionEvent {
  final FeeCollection collection;

  const UpdateFeeCollection(this.collection);

  @override
  List<Object?> get props => [collection];
}

class DeleteFeeCollection extends FeeCollectionEvent {
  final String id;

  const DeleteFeeCollection(this.id);

  @override
  List<Object?> get props => [id];
}

class GenerateReceiptNumber extends FeeCollectionEvent {
  const GenerateReceiptNumber();
}

class CollectBulkFee extends FeeCollectionEvent {
  final String schoolId;
  final String studentId;
  final String collectedBy;
  final List<Map<String, dynamic>> feeCollections;
  final double amountGiven;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String receiptNumber;
  final String? notes;

  const CollectBulkFee({
    required this.schoolId,
    required this.studentId,
    required this.collectedBy,
    required this.feeCollections,
    required this.amountGiven,
    required this.paymentDate,
    required this.paymentMethod,
    required this.receiptNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [
        schoolId,
        studentId,
        collectedBy,
        feeCollections,
        amountGiven,
        paymentDate,
        paymentMethod,
        receiptNumber,
        notes,
      ];
}
