// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OTPRequestModel _$OTPRequestModelFromJson(Map<String, dynamic> json) =>
    OTPRequestModel(
      phoneNumber: json['phoneNumber'] as String,
      deviceId: json['deviceId'] as String?,
      appVersion: json['appVersion'] as String?,
    );

Map<String, dynamic> _$OTPRequestModelToJson(OTPRequestModel instance) =>
    <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'deviceId': instance.deviceId,
      'appVersion': instance.appVersion,
    };
