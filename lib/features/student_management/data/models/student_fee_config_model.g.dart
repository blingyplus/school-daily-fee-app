// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_fee_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentFeeConfigModel _$StudentFeeConfigModelFromJson(
        Map<String, dynamic> json) =>
    StudentFeeConfigModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      canteenDailyFee: (json['canteenDailyFee'] as num).toDouble(),
      transportDailyFee: (json['transportDailyFee'] as num).toDouble(),
      transportLocation: json['transportLocation'] as String?,
      canteenEnabled: json['canteenEnabled'] as bool,
      transportEnabled: json['transportEnabled'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$StudentFeeConfigModelToJson(
        StudentFeeConfigModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'canteenDailyFee': instance.canteenDailyFee,
      'transportDailyFee': instance.transportDailyFee,
      'transportLocation': instance.transportLocation,
      'canteenEnabled': instance.canteenEnabled,
      'transportEnabled': instance.transportEnabled,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
