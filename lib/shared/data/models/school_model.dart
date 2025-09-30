import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/school.dart';

part 'school_model.g.dart';

@JsonSerializable()
class SchoolModel {
  final String id;
  final String name;
  final String code;
  final String address;
  @JsonKey(name: 'contact_phone')
  final String contactPhone;
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @JsonKey(name: 'subscription_tier')
  final String subscriptionTier;
  @JsonKey(name: 'subscription_expires_at')
  final int? subscriptionExpiresAt;
  final String? settings;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  const SchoolModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.contactPhone,
    this.contactEmail,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    this.settings,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolModelToJson(this);

  /// Convert to SQLite-compatible JSON
  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'subscription_tier': subscriptionTier,
      'subscription_expires_at': subscriptionExpiresAt,
      'settings': settings,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to Supabase-compatible JSON (with ISO timestamp strings)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'subscription_tier': subscriptionTier,
      'subscription_expires_at': subscriptionExpiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionExpiresAt!)
              .toIso8601String()
          : null,
      'settings': settings,
      'is_active': isActive,
      'created_at':
          DateTime.fromMillisecondsSinceEpoch(createdAt).toIso8601String(),
      'updated_at':
          DateTime.fromMillisecondsSinceEpoch(updatedAt).toIso8601String(),
    };
  }

  /// Create from SQLite JSON
  factory SchoolModel.fromSqliteJson(Map<String, dynamic> json) {
    return SchoolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      address: json['address'] as String,
      contactPhone: json['contact_phone'] as String,
      contactEmail: json['contact_email'] as String?,
      subscriptionTier: json['subscription_tier'] as String,
      subscriptionExpiresAt: json['subscription_expires_at'] as int?,
      settings: json['settings'] as String?,
      isActive: (json['is_active'] as int) == 1,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  School toEntity() {
    return School(
      id: id,
      name: name,
      code: code,
      address: address,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      subscriptionTier: subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(subscriptionExpiresAt!)
          : null,
      settings: settings,
      isActive: isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  factory SchoolModel.fromEntity(School school) {
    return SchoolModel(
      id: school.id,
      name: school.name,
      code: school.code,
      address: school.address,
      contactPhone: school.contactPhone,
      contactEmail: school.contactEmail,
      subscriptionTier: school.subscriptionTier,
      subscriptionExpiresAt:
          school.subscriptionExpiresAt?.millisecondsSinceEpoch,
      settings: school.settings,
      isActive: school.isActive,
      createdAt: school.createdAt.millisecondsSinceEpoch,
      updatedAt: school.updatedAt.millisecondsSinceEpoch,
    );
  }
}
