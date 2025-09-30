import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

part 'fee_collection_model.g.dart';

@JsonSerializable()
class FeeCollectionModel extends FeeCollection {
  const FeeCollectionModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.collectedBy,
    required super.feeType,
    required super.amountPaid,
    required super.paymentDate,
    required super.coverageStartDate,
    required super.coverageEndDate,
    required super.paymentMethod,
    required super.receiptNumber,
    super.notes,
    required super.collectedAt,
    super.syncedAt,
    required super.syncStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FeeCollectionModel.fromJson(Map<String, dynamic> json) =>
      _$FeeCollectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$FeeCollectionModelToJson(this);

  factory FeeCollectionModel.fromEntity(FeeCollection collection) {
    return FeeCollectionModel(
      id: collection.id,
      schoolId: collection.schoolId,
      studentId: collection.studentId,
      collectedBy: collection.collectedBy,
      feeType: collection.feeType,
      amountPaid: collection.amountPaid,
      paymentDate: collection.paymentDate,
      coverageStartDate: collection.coverageStartDate,
      coverageEndDate: collection.coverageEndDate,
      paymentMethod: collection.paymentMethod,
      receiptNumber: collection.receiptNumber,
      notes: collection.notes,
      collectedAt: collection.collectedAt,
      syncedAt: collection.syncedAt,
      syncStatus: collection.syncStatus,
      createdAt: collection.createdAt,
      updatedAt: collection.updatedAt,
    );
  }

  FeeCollection toEntity() {
    return FeeCollection(
      id: id,
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
      collectedAt: collectedAt,
      syncedAt: syncedAt,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FeeCollectionModel.fromMap(Map<String, dynamic> map) {
    return FeeCollectionModel(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      collectedBy: map['collected_by'] as String,
      feeType: FeeType.values.firstWhere(
        (e) => e.name == map['fee_type'],
        orElse: () => FeeType.canteen,
      ),
      amountPaid: (map['amount_paid'] as num).toDouble(),
      paymentDate:
          DateTime.fromMillisecondsSinceEpoch(map['payment_date'] as int),
      coverageStartDate: DateTime.fromMillisecondsSinceEpoch(
          map['coverage_start_date'] as int),
      coverageEndDate:
          DateTime.fromMillisecondsSinceEpoch(map['coverage_end_date'] as int),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['payment_method'],
        orElse: () => PaymentMethod.cash,
      ),
      receiptNumber: map['receipt_number'] as String,
      notes: map['notes'] as String?,
      collectedAt:
          DateTime.fromMillisecondsSinceEpoch(map['collected_at'] as int),
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
      syncStatus: map['sync_status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'collected_by': collectedBy,
      'fee_type': feeType.name,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.millisecondsSinceEpoch,
      'coverage_start_date': coverageStartDate.millisecondsSinceEpoch,
      'coverage_end_date': coverageEndDate.millisecondsSinceEpoch,
      'payment_method': paymentMethod.name,
      'receipt_number': receiptNumber,
      'notes': notes,
      'collected_at': collectedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
