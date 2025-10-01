import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_students_usecase.dart';
import '../../domain/usecases/search_students_usecase.dart';
import '../../domain/usecases/create_student_usecase.dart';
import '../../domain/usecases/update_student_usecase.dart';
import '../../domain/usecases/delete_student_usecase.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final GetStudentsUseCase _getStudentsUseCase;
  final SearchStudentsUseCase _searchStudentsUseCase;
  final CreateStudentUseCase _createStudentUseCase;
  final UpdateStudentUseCase _updateStudentUseCase;
  final DeleteStudentUseCase _deleteStudentUseCase;

  StudentBloc({
    required GetStudentsUseCase getStudentsUseCase,
    required SearchStudentsUseCase searchStudentsUseCase,
    required CreateStudentUseCase createStudentUseCase,
    required UpdateStudentUseCase updateStudentUseCase,
    required DeleteStudentUseCase deleteStudentUseCase,
  })  : _getStudentsUseCase = getStudentsUseCase,
        _searchStudentsUseCase = searchStudentsUseCase,
        _createStudentUseCase = createStudentUseCase,
        _updateStudentUseCase = updateStudentUseCase,
        _deleteStudentUseCase = deleteStudentUseCase,
        super(StudentInitial()) {
    on<LoadStudents>(_onLoadStudents);
    on<SearchStudents>(_onSearchStudents);
    on<LoadStudentsByClass>(_onLoadStudentsByClass);
    on<LoadStudentById>(_onLoadStudentById);
    on<CreateStudent>(_onCreateStudent);
    on<UpdateStudent>(_onUpdateStudent);
    on<DeleteStudent>(_onDeleteStudent);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onLoadStudents(
      LoadStudents event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final students = await _getStudentsUseCase(event.schoolId);
      emit(StudentLoaded(students: students));
    } catch (e) {
      emit(StudentError('Failed to load students: $e'));
    }
  }

  Future<void> _onSearchStudents(
      SearchStudents event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final students =
          await _searchStudentsUseCase(event.schoolId, event.query);
      emit(StudentLoaded(
        students: students,
        searchQuery: event.query,
      ));
    } catch (e) {
      emit(StudentError('Failed to search students: $e'));
    }
  }

  Future<void> _onLoadStudentsByClass(
      LoadStudentsByClass event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // For now, we'll use the general get students and filter by class
      // This can be optimized later with a specific use case
      final students = await _getStudentsUseCase(''); // We need schoolId here
      final classStudents =
          students.where((s) => s.classId == event.classId).toList();
      emit(StudentLoaded(
        students: classStudents,
        classId: event.classId,
      ));
    } catch (e) {
      emit(StudentError('Failed to load students by class: $e'));
    }
  }

  Future<void> _onLoadStudentById(
      LoadStudentById event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      // For now, we'll load all students and find the specific one
      // This can be optimized later with a specific use case
      final students = await _getStudentsUseCase(''); // We need schoolId here
      final student =
          students.where((s) => s.id == event.studentId).firstOrNull;
      if (student != null) {
        emit(StudentLoaded(students: [student]));
      } else {
        emit(StudentError('Student not found'));
      }
    } catch (e) {
      emit(StudentError('Failed to load student: $e'));
    }
  }

  Future<void> _onCreateStudent(
      CreateStudent event, Emitter<StudentState> emit) async {
    emit(StudentOperationLoading());
    try {
      await _createStudentUseCase(
        schoolId: event.schoolId,
        classId: event.classId,
        studentId: event.studentId,
        firstName: event.firstName,
        lastName: event.lastName,
        dateOfBirth: event.dateOfBirth,
        photoUrl: event.photoUrl,
        parentPhone: event.parentPhone,
        parentEmail: event.parentEmail,
        address: event.address,
      );

      // Reload students after creation
      final students = await _getStudentsUseCase(event.schoolId);
      emit(StudentOperationSuccess(
        message: 'Student created successfully',
        students: students,
      ));
    } catch (e) {
      emit(StudentError('Failed to create student: $e'));
    }
  }

  Future<void> _onUpdateStudent(
      UpdateStudent event, Emitter<StudentState> emit) async {
    emit(StudentOperationLoading());
    try {
      await _updateStudentUseCase(event.student);

      // Reload students after update
      final students = await _getStudentsUseCase(event.student.schoolId);
      emit(StudentOperationSuccess(
        message: 'Student updated successfully',
        students: students,
      ));
    } catch (e) {
      emit(StudentError('Failed to update student: $e'));
    }
  }

  Future<void> _onDeleteStudent(
      DeleteStudent event, Emitter<StudentState> emit) async {
    emit(StudentOperationLoading());
    try {
      await _deleteStudentUseCase(event.id);

      // Reload students after deletion
      final students = await _getStudentsUseCase(''); // We need schoolId here
      emit(StudentOperationSuccess(
        message: 'Student deleted successfully',
        students: students,
      ));
    } catch (e) {
      emit(StudentError('Failed to delete student: $e'));
    }
  }

  Future<void> _onClearSearch(
      ClearSearch event, Emitter<StudentState> emit) async {
    emit(StudentLoading());
    try {
      final students = await _getStudentsUseCase(event.schoolId);
      emit(StudentLoaded(students: students));
    } catch (e) {
      emit(StudentError('Failed to clear search: $e'));
    }
  }
}
