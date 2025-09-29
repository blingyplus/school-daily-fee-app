// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      otpHash: json['otpHash'] as String?,
      otpExpiresAt: (json['otp_expires_at'] as num?)?.toInt(),
      lastLogin: (json['last_login'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: (json['created_at'] as num).toInt(),
      updatedAt: (json['updated_at'] as num).toInt(),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'phoneNumber': instance.phoneNumber,
      'otpHash': instance.otpHash,
      'otp_expires_at': instance.otpExpiresAt,
      'last_login': instance.lastLogin,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
