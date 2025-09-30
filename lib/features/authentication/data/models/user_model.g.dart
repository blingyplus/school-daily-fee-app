// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      otpHash: json['otp_hash'] as String?,
      otpExpiresAt: (json['otp_expires_at'] as num?)?.toInt(),
      lastLogin: (json['last_login'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'phone_number': instance.phoneNumber,
      'otp_hash': instance.otpHash,
      'otp_expires_at': instance.otpExpiresAt,
      'last_login': instance.lastLogin,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
