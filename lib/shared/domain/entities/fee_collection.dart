import 'package:equatable/equatable.dart';

enum FeeType { canteen, transport }

enum PaymentMethod { cash, card, upi, cheque }

class FeeCollection extends Equatable {
  final String id;
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
  final DateTime collectedAt;
  final DateTime? syncedAt;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FeeCollection({
    required this.id,
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
    required this.collectedAt,
    this.syncedAt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  int get coverageDays => coverageEndDate.difference(coverageStartDate).inDays + 1;

  @override
  List<Object?> get props => [
        id,
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
        collectedAt,
        syncedAt,
        syncStatus,
        createdAt,
        updatedAt,
      ];

  FeeCollection copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? collectedBy,
    FeeType? feeType,
    double? amountPaid,
    DateTime? paymentDate,
    DateTime? coverageStartDate,
    DateTime? coverageEndDate,
    PaymentMethod? paymentMethod,
    String? receiptNumber,
    String? notes,
    DateTime? collectedAt,
    DateTime? syncedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeeCollection(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      collectedBy: collectedBy ?? this.collectedBy,
      feeType: feeType ?? this.feeType,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentDate: paymentDate ?? this.paymentDate,
      coverageStartDate: coverageStartDate ?? this.coverageStartDate,
      coverageEndDate: coverageEndDate ?? this.coverageEndDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
      collectedAt: collectedAt ?? this.collectedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
