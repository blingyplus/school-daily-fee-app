// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolModel _$SchoolModelFromJson(Map<String, dynamic> json) => SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String?,
      subscriptionTier: json['subscription_tier'] as String,
      subscriptionExpiresAt: (json['subscription_expires_at'] as num?)?.toInt(),
      settings: json['settings'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$SchoolModelToJson(SchoolModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'contact_phone': instance.contactPhone,
      'contact_email': instance.contactEmail,
      'subscription_tier': instance.subscriptionTier,
      'subscription_expires_at': instance.subscriptionExpiresAt,
      'settings': instance.settings,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
