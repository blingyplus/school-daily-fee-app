import 'package:json_annotation/json_annotation.dart';

import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/data/utils/sqlite_converter.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @JsonKey(name: 'otp_hash')
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

  /// Create from SQLite JSON (integers as booleans)
  factory UserModel.fromSqliteJson(Map<String, dynamic> json) {
    return UserModel(
      id: SqliteConverter.safeString(json['id']),
      phoneNumber: SqliteConverter.safeString(json['phone_number']),
      otpHash: SqliteConverter.safeStringNullable(json['otp_hash']),
      otpExpiresAt: SqliteConverter.safeIntNullable(json['otp_expires_at']),
      lastLogin: SqliteConverter.safeIntNullable(json['last_login']),
      isActive: SqliteConverter.safeBool(
          json['is_active']), // Convert integer to boolean
      createdAt: SqliteConverter.safeInt(json['created_at']),
      updatedAt: SqliteConverter.safeInt(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Convert to SQLite-compatible JSON (booleans as integers)
  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'otp_hash': otpHash,
      'otp_expires_at': otpExpiresAt,
      'last_login': lastLogin,
      'is_active': isActive ? 1 : 0, // Convert boolean to integer
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

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
