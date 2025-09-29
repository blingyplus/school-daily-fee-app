import 'package:equatable/equatable.dart';

class SchoolClass extends Equatable {
  final String id;
  final String schoolId;
  final String name;
  final String gradeLevel;
  final String section;
  final int academicYear;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SchoolClass({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.gradeLevel,
    required this.section,
    required this.academicYear,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => '$gradeLevel - $section';

  @override
  List<Object?> get props => [
        id,
        schoolId,
        name,
        gradeLevel,
        section,
        academicYear,
        isActive,
        createdAt,
        updatedAt,
      ];

  SchoolClass copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? gradeLevel,
    String? section,
    int? academicYear,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      section: section ?? this.section,
      academicYear: academicYear ?? this.academicYear,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
