import 'package:json_annotation/json_annotation.dart';

import '../../../../shared/domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String phoneNumber;
  final String? otpHash;
  @JsonKey(name: 'otp_expires_at')
  final int? otpExpiresAt;
  @JsonKey(name: 'last_login')
  final int? lastLogin;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.otpHash,
    this.otpExpiresAt,
    this.lastLogin,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phoneNumber: user.phoneNumber,
      otpHash: user.otpHash,
      otpExpiresAt: user.otpExpiresAt?.millisecondsSinceEpoch,
      lastLogin: user.lastLogin?.millisecondsSinceEpoch,
      isActive: user.isActive,
      createdAt: user.createdAt.millisecondsSinceEpoch,
      updatedAt: user.updatedAt.millisecondsSinceEpoch,
    );
  }

  User toEntity() {
    return User(
      id: id,
      phoneNumber: phoneNumber,
      otpHash: otpHash,
      otpExpiresAt: otpExpiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(otpExpiresAt!)
          : null,
      lastLogin: lastLogin != null
          ? DateTime.fromMillisecondsSinceEpoch(lastLogin!)
          : null,
      isActive: isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? otpHash,
    int? otpExpiresAt,
    int? lastLogin,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpHash: otpHash ?? this.otpHash,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
