import 'package:equatable/equatable.dart';

class Holiday extends Equatable {
  final String id;
  final String schoolId;
  final DateTime holidayDate;
  final String name;
  final String? description;
  final bool isRecurring;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Holiday({
    required this.id,
    required this.schoolId,
    required this.holidayDate,
    required this.name,
    this.description,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        holidayDate,
        name,
        description,
        isRecurring,
        createdAt,
        updatedAt,
      ];

  Holiday copyWith({
    String? id,
    String? schoolId,
    DateTime? holidayDate,
    String? name,
    String? description,
    bool? isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Holiday(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      holidayDate: holidayDate ?? this.holidayDate,
      name: name ?? this.name,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
