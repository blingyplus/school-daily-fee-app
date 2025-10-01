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
      id: map['id'].toString(),
      studentId: map['student_id'].toString(),
      canteenDailyFee: _parseDouble(map['canteen_daily_fee']),
      transportDailyFee: _parseDouble(map['transport_daily_fee']),
      transportLocation: map['transport_location']?.toString(),
      canteenEnabled: _parseInt(map['canteen_enabled']) == 1,
      transportEnabled: _parseInt(map['transport_enabled']) == 1,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['created_at'])),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['updated_at'])),
    );
  }

  /// Helper method to safely parse integer values from database
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  /// Helper method to safely parse double values from database
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
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
