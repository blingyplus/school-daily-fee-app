import 'package:equatable/equatable.dart';

enum TeacherRole { admin, staff }

class SchoolTeacher extends Equatable {
  final String id;
  final String schoolId;
  final String teacherId;
  final TeacherRole role;
  final List<String> assignedClasses;
  final bool isActive;
  final DateTime assignedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SchoolTeacher({
    required this.id,
    required this.schoolId,
    required this.teacherId,
    required this.role,
    required this.assignedClasses,
    required this.isActive,
    required this.assignedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        teacherId,
        role,
        assignedClasses,
        isActive,
        assignedAt,
        createdAt,
        updatedAt,
      ];

  SchoolTeacher copyWith({
    String? id,
    String? schoolId,
    String? teacherId,
    TeacherRole? role,
    List<String>? assignedClasses,
    bool? isActive,
    DateTime? assignedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolTeacher(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      role: role ?? this.role,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      isActive: isActive ?? this.isActive,
      assignedAt: assignedAt ?? this.assignedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
