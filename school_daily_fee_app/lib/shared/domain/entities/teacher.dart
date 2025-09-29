import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Teacher({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        userId,
        firstName,
        lastName,
        employeeId,
        photoUrl,
        createdAt,
        updatedAt,
      ];

  Teacher copyWith({
    String? id,
    String? userId,
    String? firstName,
    String? lastName,
    String? employeeId,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      employeeId: employeeId ?? this.employeeId,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
