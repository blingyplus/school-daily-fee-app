import 'package:equatable/equatable.dart';

class School extends Equatable {
  final String id;
  final String name;
  final String code;
  final String address;
  final String contactPhone;
  final String contactEmail;
  final String subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final Map<String, dynamic> settings;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const School({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.contactPhone,
    required this.contactEmail,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        address,
        contactPhone,
        contactEmail,
        subscriptionTier,
        subscriptionExpiresAt,
        settings,
        isActive,
        createdAt,
        updatedAt,
      ];

  School copyWith({
    String? id,
    String? name,
    String? code,
    String? address,
    String? contactPhone,
    String? contactEmail,
    String? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    Map<String, dynamic>? settings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      settings: settings ?? this.settings,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
