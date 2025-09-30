import 'package:json_annotation/json_annotation.dart';

part 'admin_model.g.dart';

@JsonSerializable()
class AdminModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'school_id')
  final String schoolId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  const AdminModel({
    required this.id,
    required this.userId,
    required this.schoolId,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) =>
      _$AdminModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminModelToJson(this);

  /// Convert to SQLite-compatible JSON
  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'user_id': userId,
      'school_id': schoolId,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to Supabase-compatible JSON (with ISO timestamp strings)
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'user_id': userId,
      'school_id': schoolId,
      'first_name': firstName,
      'last_name': lastName,
      'photo_url': photoUrl,
      'created_at':
          DateTime.fromMillisecondsSinceEpoch(createdAt).toIso8601String(),
      'updated_at':
          DateTime.fromMillisecondsSinceEpoch(updatedAt).toIso8601String(),
    };
  }

  /// Create from SQLite JSON
  factory AdminModel.fromSqliteJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      schoolId: json['school_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }
}
