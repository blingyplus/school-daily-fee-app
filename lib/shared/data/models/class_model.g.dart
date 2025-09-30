// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      gradeLevel: json['grade_level'] as String,
      section: json['section'] as String,
      academicYear: (json['academic_year'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'name': instance.name,
      'grade_level': instance.gradeLevel,
      'section': instance.section,
      'academic_year': instance.academicYear,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
