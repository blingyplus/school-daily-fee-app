import 'package:json_annotation/json_annotation.dart';
import '../utils/sqlite_converter.dart';

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
      id: SqliteConverter.safeString(json['id']),
      userId: SqliteConverter.safeString(json['user_id']),
      schoolId: SqliteConverter.safeString(json['school_id']),
      firstName: SqliteConverter.safeString(json['first_name']),
      lastName: SqliteConverter.safeString(json['last_name']),
      photoUrl: SqliteConverter.safeStringNullable(json['photo_url']),
      createdAt: SqliteConverter.safeInt(json['created_at']),
      updatedAt: SqliteConverter.safeInt(json['updated_at']),
    );
  }
}
