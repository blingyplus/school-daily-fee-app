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
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      classId: map['class_id'] as String,
      studentId: map['student_id'] as String,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_of_birth'] as int)
          : null,
      photoUrl: map['photo_url'] as String?,
      parentPhone: map['parent_phone'] as String?,
      parentEmail: map['parent_email'] as String?,
      address: map['address'] as String?,
      isActive: (map['is_active'] as int) == 1,
      enrolledAt: map['enrolled_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['enrolled_at'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
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
