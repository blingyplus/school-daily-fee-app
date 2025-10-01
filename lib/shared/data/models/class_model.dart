import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/school_class.dart';
import '../utils/sqlite_converter.dart';

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
      id: SqliteConverter.safeString(json['id']),
      schoolId: SqliteConverter.safeString(json['school_id']),
      name: SqliteConverter.safeString(json['name']),
      gradeLevel: SqliteConverter.safeString(json['grade_level']),
      section: SqliteConverter.safeString(json['section']),
      academicYear: SqliteConverter.safeInt(json['academic_year']),
      isActive: SqliteConverter.safeBool(json['is_active']),
      createdAt: SqliteConverter.safeInt(json['created_at']),
      updatedAt: SqliteConverter.safeInt(json['updated_at']),
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
