import 'package:equatable/equatable.dart';

class Student extends Equatable {
  final String id;
  final String schoolId;
  final String classId;
  final String studentId;
  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String? parentPhone;
  final String? parentEmail;
  final String? address;
  final bool isActive;
  final DateTime? enrolledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.photoUrl,
    this.parentPhone,
    this.parentEmail,
    this.address,
    required this.isActive,
    this.enrolledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        schoolId,
        classId,
        studentId,
        firstName,
        lastName,
        dateOfBirth,
        photoUrl,
        parentPhone,
        parentEmail,
        address,
        isActive,
        enrolledAt,
        createdAt,
        updatedAt,
      ];

  Student copyWith({
    String? id,
    String? schoolId,
    String? classId,
    String? studentId,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? parentPhone,
    String? parentEmail,
    String? address,
    bool? isActive,
    DateTime? enrolledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoUrl: photoUrl ?? this.photoUrl,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
