import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/student.dart';

abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadStudents extends StudentEvent {
  final String schoolId;

  const LoadStudents(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}

class SearchStudents extends StudentEvent {
  final String schoolId;
  final String query;

  const SearchStudents(this.schoolId, this.query);

  @override
  List<Object?> get props => [schoolId, query];
}

class LoadStudentsByClass extends StudentEvent {
  final String classId;

  const LoadStudentsByClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadStudentById extends StudentEvent {
  final String studentId;

  const LoadStudentById(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class CreateStudent extends StudentEvent {
  final String schoolId;
  final String classId;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String? parentPhone;
  final String? parentEmail;
  final String? address;

  const CreateStudent({
    required this.schoolId,
    required this.classId,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.parentPhone,
    this.parentEmail,
    this.address,
  });

  @override
  List<Object?> get props => [
        schoolId,
        classId,
        firstName,
        lastName,
        photoUrl,
        parentPhone,
        parentEmail,
        address,
      ];
}

class UpdateStudent extends StudentEvent {
  final Student student;

  const UpdateStudent(this.student);

  @override
  List<Object?> get props => [student];
}

class DeleteStudent extends StudentEvent {
  final String id;

  const DeleteStudent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearSearch extends StudentEvent {
  final String schoolId;

  const ClearSearch(this.schoolId);

  @override
  List<Object?> get props => [schoolId];
}
