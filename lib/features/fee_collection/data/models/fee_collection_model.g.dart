// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_collection_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeeCollectionModel _$FeeCollectionModelFromJson(Map<String, dynamic> json) =>
    FeeCollectionModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      studentId: json['studentId'] as String,
      collectedBy: json['collectedBy'] as String,
      feeType: $enumDecode(_$FeeTypeEnumMap, json['feeType']),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      coverageStartDate: DateTime.parse(json['coverageStartDate'] as String),
      coverageEndDate: DateTime.parse(json['coverageEndDate'] as String),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      receiptNumber: json['receiptNumber'] as String,
      notes: json['notes'] as String?,
      collectedAt: DateTime.parse(json['collectedAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      syncStatus: json['syncStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FeeCollectionModelToJson(FeeCollectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'studentId': instance.studentId,
      'collectedBy': instance.collectedBy,
      'feeType': _$FeeTypeEnumMap[instance.feeType]!,
      'amountPaid': instance.amountPaid,
      'paymentDate': instance.paymentDate.toIso8601String(),
      'coverageStartDate': instance.coverageStartDate.toIso8601String(),
      'coverageEndDate': instance.coverageEndDate.toIso8601String(),
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'receiptNumber': instance.receiptNumber,
      'notes': instance.notes,
      'collectedAt': instance.collectedAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$FeeTypeEnumMap = {
  FeeType.canteen: 'canteen',
  FeeType.transport: 'transport',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.upi: 'upi',
  PaymentMethod.cheque: 'cheque',
};
