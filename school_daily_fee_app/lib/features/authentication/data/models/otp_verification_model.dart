import 'package:json_annotation/json_annotation.dart';

part 'otp_verification_model.g.dart';

@JsonSerializable()
class OTPVerificationModel {
  final String phoneNumber;
  final String otp;
  final String? deviceId;

  const OTPVerificationModel({
    required this.phoneNumber,
    required this.otp,
    this.deviceId,
  });

  factory OTPVerificationModel.fromJson(Map<String, dynamic> json) =>
      _$OTPVerificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$OTPVerificationModelToJson(this);

  OTPVerificationModel copyWith({
    String? phoneNumber,
    String? otp,
    String? deviceId,
  }) {
    return OTPVerificationModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
