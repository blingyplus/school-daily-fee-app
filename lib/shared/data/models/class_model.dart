import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/school_class.dart';

part 'class_model.g.dart';

@JsonSerializable()
class ClassModel {
  final String id;
  @JsonKey(name: 'school_id')
  final String schoolId;
  final String name;
  @JsonKey(name: 'grade_level')
  final String gradeLevel;
  final String section;
  @JsonKey(name: 'academic_year')
  final int academicYear;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  const ClassModel({
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

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClassModelToJson(this);

  /// Convert to SQLite-compatible JSON
  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'grade_level': gradeLevel,
      'section': section,
      'academic_year': academicYear,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to Supabase-compatible JSON (with ISO timestamp strings)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'grade_level': gradeLevel,
      'section': section,
      'academic_year': academicYear,
      'is_active': isActive,
      'created_at':
          DateTime.fromMillisecondsSinceEpoch(createdAt).toIso8601String(),
      'updated_at':
          DateTime.fromMillisecondsSinceEpoch(updatedAt).toIso8601String(),
    };
  }

  /// Create from SQLite JSON
  factory ClassModel.fromSqliteJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      gradeLevel: json['grade_level'] as String,
      section: json['section'] as String,
      academicYear: json['academic_year'] as int,
      isActive: (json['is_active'] as int) == 1,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  SchoolClass toEntity() {
    return SchoolClass(
      id: id,
      schoolId: schoolId,
      name: name,
      gradeLevel: gradeLevel,
      section: section,
      academicYear: academicYear,
      isActive: isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  factory ClassModel.fromEntity(SchoolClass schoolClass) {
    return ClassModel(
      id: schoolClass.id,
      schoolId: schoolClass.schoolId,
      name: schoolClass.name,
      gradeLevel: schoolClass.gradeLevel,
      section: schoolClass.section,
      academicYear: schoolClass.academicYear,
      isActive: schoolClass.isActive,
      createdAt: schoolClass.createdAt.millisecondsSinceEpoch,
      updatedAt: schoolClass.updatedAt.millisecondsSinceEpoch,
    );
  }
}
