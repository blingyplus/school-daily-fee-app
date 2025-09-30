import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/teacher.dart';

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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      employeeId: json['employee_id'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
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
