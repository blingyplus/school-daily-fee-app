import 'package:equatable/equatable.dart';

enum ScholarshipType { percentage, fixed, full }

class Scholarship extends Equatable {
  final String id;
  final String studentId;
  final ScholarshipType type;
  final double? discountPercentage;
  final double? fixedDiscount;
  final String description;
  final DateTime validFrom;
  final DateTime? validUntil;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Scholarship({
    required this.id,
    required this.studentId,
    required this.type,
    this.discountPercentage,
    this.fixedDiscount,
    required this.description,
    required this.validFrom,
    this.validUntil,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isValid {
    final now = DateTime.now();
    if (now.isBefore(validFrom)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    return isActive;
  }

  double calculateDiscount(double amount) {
    switch (type) {
      case ScholarshipType.percentage:
        return amount * (discountPercentage ?? 0) / 100;
      case ScholarshipType.fixed:
        return fixedDiscount ?? 0;
      case ScholarshipType.full:
        return amount;
    }
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        type,
        discountPercentage,
        fixedDiscount,
        description,
        validFrom,
        validUntil,
        isActive,
        createdAt,
        updatedAt,
      ];

  Scholarship copyWith({
    String? id,
    String? studentId,
    ScholarshipType? type,
    double? discountPercentage,
    double? fixedDiscount,
    String? description,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Scholarship(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      description: description ?? this.description,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
