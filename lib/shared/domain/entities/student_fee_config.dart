import 'package:equatable/equatable.dart';

class StudentFeeConfig extends Equatable {
  final String id;
  final String studentId;
  final double canteenDailyFee;
  final double transportDailyFee;
  final String? transportLocation;
  final bool canteenEnabled;
  final bool transportEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentFeeConfig({
    required this.id,
    required this.studentId,
    required this.canteenDailyFee,
    required this.transportDailyFee,
    this.transportLocation,
    required this.canteenEnabled,
    required this.transportEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalDailyFee {
    double total = 0.0;
    if (canteenEnabled) total += canteenDailyFee;
    if (transportEnabled) total += transportDailyFee;
    return total;
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        canteenDailyFee,
        transportDailyFee,
        transportLocation,
        canteenEnabled,
        transportEnabled,
        createdAt,
        updatedAt,
      ];

  StudentFeeConfig copyWith({
    String? id,
    String? studentId,
    double? canteenDailyFee,
    double? transportDailyFee,
    String? transportLocation,
    bool? canteenEnabled,
    bool? transportEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentFeeConfig(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      canteenDailyFee: canteenDailyFee ?? this.canteenDailyFee,
      transportDailyFee: transportDailyFee ?? this.transportDailyFee,
      transportLocation: transportLocation ?? this.transportLocation,
      canteenEnabled: canteenEnabled ?? this.canteenEnabled,
      transportEnabled: transportEnabled ?? this.transportEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
