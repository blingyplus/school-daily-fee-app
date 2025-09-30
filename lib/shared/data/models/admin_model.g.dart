// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminModel _$AdminModelFromJson(Map<String, dynamic> json) => AdminModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      schoolId: json['school_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$AdminModelToJson(AdminModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'school_id': instance.schoolId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'photo_url': instance.photoUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
