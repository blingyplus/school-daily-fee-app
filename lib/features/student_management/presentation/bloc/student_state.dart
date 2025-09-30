import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/student.dart';

abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final List<Student> students;
  final String? searchQuery;
  final String? classId;

  const StudentLoaded({
    required this.students,
    this.searchQuery,
    this.classId,
  });

  @override
  List<Object?> get props => [students, searchQuery, classId];

  StudentLoaded copyWith({
    List<Student>? students,
    String? searchQuery,
    String? classId,
  }) {
    return StudentLoaded(
      students: students ?? this.students,
      searchQuery: searchQuery ?? this.searchQuery,
      classId: classId ?? this.classId,
    );
  }
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

class StudentOperationSuccess extends StudentState {
  final String message;
  final List<Student> students;

  const StudentOperationSuccess({
    required this.message,
    required this.students,
  });

  @override
  List<Object?> get props => [message, students];
}

class StudentOperationLoading extends StudentState {}
