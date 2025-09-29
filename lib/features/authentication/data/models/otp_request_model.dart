import 'package:json_annotation/json_annotation.dart';

part 'otp_request_model.g.dart';

@JsonSerializable()
class OTPRequestModel {
  final String phoneNumber;
  final String? deviceId;
  final String? appVersion;

  const OTPRequestModel({
    required this.phoneNumber,
    this.deviceId,
    this.appVersion,
  });

  factory OTPRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OTPRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OTPRequestModelToJson(this);

  OTPRequestModel copyWith({
    String? phoneNumber,
    String? deviceId,
    String? appVersion,
  }) {
    return OTPRequestModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deviceId: deviceId ?? this.deviceId,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
