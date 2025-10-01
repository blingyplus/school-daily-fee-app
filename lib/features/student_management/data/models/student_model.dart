import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/domain/entities/student.dart';

part 'student_model.g.dart';

@JsonSerializable()
class StudentModel extends Student {
  const StudentModel({
    required super.id,
    required super.schoolId,
    required super.classId,
    required super.studentId,
    required super.firstName,
    required super.lastName,
    super.dateOfBirth,
    super.photoUrl,
    super.parentPhone,
    super.parentEmail,
    super.address,
    required super.isActive,
    super.enrolledAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      _$StudentModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentModelToJson(this);

  factory StudentModel.fromEntity(Student student) {
    return StudentModel(
      id: student.id,
      schoolId: student.schoolId,
      classId: student.classId,
      studentId: student.studentId,
      firstName: student.firstName,
      lastName: student.lastName,
      dateOfBirth: student.dateOfBirth,
      photoUrl: student.photoUrl,
      parentPhone: student.parentPhone,
      parentEmail: student.parentEmail,
      address: student.address,
      isActive: student.isActive,
      enrolledAt: student.enrolledAt,
      createdAt: student.createdAt,
      updatedAt: student.updatedAt,
    );
  }

  Student toEntity() {
    return Student(
      id: id,
      schoolId: schoolId,
      classId: classId,
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      photoUrl: photoUrl,
      parentPhone: parentPhone,
      parentEmail: parentEmail,
      address: address,
      isActive: isActive,
      enrolledAt: enrolledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'].toString(),
      schoolId: map['school_id'].toString(),
      classId: map['class_id'].toString(),
      studentId: map['student_id'].toString(),
      firstName: map['first_name'].toString(),
      lastName: map['last_name'].toString(),
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(_parseInt(map['date_of_birth']))
          : null,
      photoUrl: map['photo_url']?.toString(),
      parentPhone: map['parent_phone']?.toString(),
      parentEmail: map['parent_email']?.toString(),
      address: map['address']?.toString(),
      isActive: _parseInt(map['is_active']) == 1,
      enrolledAt: map['enrolled_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(_parseInt(map['enrolled_at']))
          : null,
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['created_at'])),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['updated_at'])),
    );
  }

  /// Helper method to safely parse integer values from database
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'class_id': classId,
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.millisecondsSinceEpoch,
      'photo_url': photoUrl,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'address': address,
      'is_active': isActive ? 1 : 0,
      'enrolled_at': enrolledAt?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
