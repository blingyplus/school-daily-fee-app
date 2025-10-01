import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/teacher.dart';
import '../utils/sqlite_converter.dart';

part 'teacher_model.g.dart';

@JsonSerializable()
class TeacherModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'employee_id')
  final String? employeeId;
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @JsonKey(name: 'created_at')
  final int createdAt;
  @JsonKey(name: 'updated_at')
  final int updatedAt;

  const TeacherModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.employeeId,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) =>
      _$TeacherModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherModelToJson(this);

  /// Convert to SQLite-compatible JSON
  Map<String, dynamic> toSqliteJson() {
    return {
      'id': id,
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'employee_id': employeeId,
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
      'first_name': firstName,
      'last_name': lastName,
      'employee_id': employeeId,
      'photo_url': photoUrl,
      'created_at':
          DateTime.fromMillisecondsSinceEpoch(createdAt).toIso8601String(),
      'updated_at':
          DateTime.fromMillisecondsSinceEpoch(updatedAt).toIso8601String(),
    };
  }

  /// Create from SQLite JSON
  factory TeacherModel.fromSqliteJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: SqliteConverter.safeString(json['id']),
      userId: SqliteConverter.safeString(json['user_id']),
      firstName: SqliteConverter.safeString(json['first_name']),
      lastName: SqliteConverter.safeString(json['last_name']),
      employeeId: SqliteConverter.safeStringNullable(json['employee_id']),
      photoUrl: SqliteConverter.safeStringNullable(json['photo_url']),
      createdAt: SqliteConverter.safeInt(json['created_at']),
      updatedAt: SqliteConverter.safeInt(json['updated_at']),
    );
  }

  Teacher toEntity() {
    return Teacher(
      id: id,
      userId: userId,
      firstName: firstName,
      lastName: lastName,
      employeeId: employeeId,
      photoUrl: photoUrl,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
    );
  }

  factory TeacherModel.fromEntity(Teacher teacher) {
    return TeacherModel(
      id: teacher.id,
      userId: teacher.userId,
      firstName: teacher.firstName,
      lastName: teacher.lastName,
      employeeId: teacher.employeeId,
      photoUrl: teacher.photoUrl,
      createdAt: teacher.createdAt.millisecondsSinceEpoch,
      updatedAt: teacher.updatedAt.millisecondsSinceEpoch,
    );
  }
}
