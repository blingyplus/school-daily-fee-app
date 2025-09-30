import 'dart:async';
import '../../domain/repositories/student_repository.dart';
import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/student_fee_config.dart';
import '../datasources/student_local_datasource.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_model.dart';
import '../models/student_fee_config_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentLocalDataSource _localDataSource;
  final StudentRemoteDataSource _remoteDataSource;

  StudentRepositoryImpl({
    required StudentLocalDataSource localDataSource,
    required StudentRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<List<Student>> getStudents(String schoolId) async {
    try {
      // Try to get from local database first
      final localStudents = await _localDataSource.getStudents(schoolId);
      return localStudents.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get students: $e');
    }
  }

  @override
  Future<Student?> getStudentById(String id) async {
    try {
      final localStudent = await _localDataSource.getStudentById(id);
      return localStudent?.toEntity();
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  @override
  Future<Student?> getStudentByStudentId(
      String schoolId, String studentId) async {
    try {
      final localStudent =
          await _localDataSource.getStudentByStudentId(schoolId, studentId);
      return localStudent?.toEntity();
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  @override
  Future<List<Student>> searchStudents(String schoolId, String query) async {
    try {
      final localStudents =
          await _localDataSource.searchStudents(schoolId, query);
      return localStudents.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search students: $e');
    }
  }

  @override
  Future<List<Student>> getStudentsByClass(String classId) async {
    try {
      final localStudents = await _localDataSource.getStudentsByClass(classId);
      return localStudents.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get students by class: $e');
    }
  }

  @override
  Future<Student> createStudent(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);

      // Save to local database first
      await _localDataSource.createStudent(studentModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return student;
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  @override
  Future<Student> updateStudent(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);

      // Update local database
      await _localDataSource.updateStudent(studentModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return student;
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      // Delete from local database
      await _localDataSource.deleteStudent(id);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  @override
  Future<StudentFeeConfig?> getStudentFeeConfig(String studentId) async {
    try {
      final localConfig = await _localDataSource.getStudentFeeConfig(studentId);
      return localConfig?.toEntity();
    } catch (e) {
      throw Exception('Failed to get student fee config: $e');
    }
  }

  @override
  Future<StudentFeeConfig> createStudentFeeConfig(
      StudentFeeConfig config) async {
    try {
      final configModel = StudentFeeConfigModel.fromEntity(config);

      // Save to local database
      await _localDataSource.createStudentFeeConfig(configModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return config;
    } catch (e) {
      throw Exception('Failed to create student fee config: $e');
    }
  }

  @override
  Future<StudentFeeConfig> updateStudentFeeConfig(
      StudentFeeConfig config) async {
    try {
      final configModel = StudentFeeConfigModel.fromEntity(config);

      // Update local database
      await _localDataSource.updateStudentFeeConfig(configModel);

      // TODO: Queue for sync to remote database
      // This will be handled by the sync engine

      return config;
    } catch (e) {
      throw Exception('Failed to update student fee config: $e');
    }
  }

  // Remote sync methods (for sync engine)
  Future<List<Student>> syncStudentsFromRemote(String schoolId) async {
    try {
      final remoteStudents = await _remoteDataSource.getStudents(schoolId);
      return remoteStudents.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to sync students from remote: $e');
    }
  }

  Future<Student> syncCreateStudentToRemote(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final remoteStudent = await _remoteDataSource.createStudent(studentModel);
      return remoteStudent.toEntity();
    } catch (e) {
      throw Exception('Failed to sync create student to remote: $e');
    }
  }

  Future<Student> syncUpdateStudentToRemote(Student student) async {
    try {
      final studentModel = StudentModel.fromEntity(student);
      final remoteStudent = await _remoteDataSource.updateStudent(studentModel);
      return remoteStudent.toEntity();
    } catch (e) {
      throw Exception('Failed to sync update student to remote: $e');
    }
  }

  Future<void> syncDeleteStudentToRemote(String id) async {
    try {
      await _remoteDataSource.deleteStudent(id);
    } catch (e) {
      throw Exception('Failed to sync delete student to remote: $e');
    }
  }
}
