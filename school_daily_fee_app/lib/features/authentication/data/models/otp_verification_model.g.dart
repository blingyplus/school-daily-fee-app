// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_verification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OTPVerificationModel _$OTPVerificationModelFromJson(
        Map<String, dynamic> json) =>
    OTPVerificationModel(
      phoneNumber: json['phoneNumber'] as String,
      otp: json['otp'] as String,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$OTPVerificationModelToJson(
        OTPVerificationModel instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'otp': instance.otp,
      'deviceId': instance.deviceId,
    };
