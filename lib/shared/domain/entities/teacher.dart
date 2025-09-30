import 'package:equatable/equatable.dart';

class Teacher extends Equatable {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String? employeeId;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Teacher({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.employeeId,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

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
}
