import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? otpHash;
  final DateTime? otpExpiresAt;
  final DateTime? lastLogin;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.phoneNumber,
    this.otpHash,
    this.otpExpiresAt,
    this.lastLogin,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        otpHash,
        otpExpiresAt,
        lastLogin,
        isActive,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? phoneNumber,
    String? otpHash,
    DateTime? otpExpiresAt,
    DateTime? lastLogin,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
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
