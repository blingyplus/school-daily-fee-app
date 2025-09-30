import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/domain/entities/student_fee_config.dart';

part 'student_fee_config_model.g.dart';

@JsonSerializable()
class StudentFeeConfigModel extends StudentFeeConfig {
  const StudentFeeConfigModel({
    required super.id,
    required super.studentId,
    required super.canteenDailyFee,
    required super.transportDailyFee,
    super.transportLocation,
    required super.canteenEnabled,
    required super.transportEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StudentFeeConfigModel.fromJson(Map<String, dynamic> json) =>
      _$StudentFeeConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentFeeConfigModelToJson(this);

  factory StudentFeeConfigModel.fromEntity(StudentFeeConfig config) {
    return StudentFeeConfigModel(
      id: config.id,
      studentId: config.studentId,
      canteenDailyFee: config.canteenDailyFee,
      transportDailyFee: config.transportDailyFee,
      transportLocation: config.transportLocation,
      canteenEnabled: config.canteenEnabled,
      transportEnabled: config.transportEnabled,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    );
  }

  StudentFeeConfig toEntity() {
    return StudentFeeConfig(
      id: id,
      studentId: studentId,
      canteenDailyFee: canteenDailyFee,
      transportDailyFee: transportDailyFee,
      transportLocation: transportLocation,
      canteenEnabled: canteenEnabled,
      transportEnabled: transportEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StudentFeeConfigModel.fromMap(Map<String, dynamic> map) {
    return StudentFeeConfigModel(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      canteenDailyFee: (map['canteen_daily_fee'] as num).toDouble(),
      transportDailyFee: (map['transport_daily_fee'] as num).toDouble(),
      transportLocation: map['transport_location'] as String?,
      canteenEnabled: (map['canteen_enabled'] as int) == 1,
      transportEnabled: (map['transport_enabled'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'canteen_daily_fee': canteenDailyFee,
      'transport_daily_fee': transportDailyFee,
      'transport_location': transportLocation,
      'canteen_enabled': canteenEnabled ? 1 : 0,
      'transport_enabled': transportEnabled ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
