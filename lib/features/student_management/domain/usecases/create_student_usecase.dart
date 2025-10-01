import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../../../../shared/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class CreateStudentUseCase {
  final StudentRepository _repository;

  CreateStudentUseCase(this._repository);

  Future<Student> call({
    required String schoolId,
    required String classId,
    required String firstName,
    required String lastName,
    String? photoUrl,
    String? parentPhone,
    String? parentEmail,
    String? address,
  }) async {
    final now = DateTime.now();
    final uuid = const Uuid();

    // Get school code to generate student ID
    final database = getIt<Database>();
    final schools = await database.query(
      DatabaseHelper.tableSchools,
      where: 'id = ?',
      whereArgs: [schoolId],
      limit: 1,
    );

    if (schools.isEmpty) {
      throw Exception('School not found');
    }

    final schoolCode = schools.first['code'] as String;

    // Auto-generate student ID
    final studentId = await IdGenerator.generateStudentId(
      schoolId: schoolId,
      schoolCode: schoolCode,
    );

    final student = Student(
      id: uuid.v4(), // Use proper UUID instead of timestamp
      schoolId: schoolId,
      classId: classId,
      studentId: studentId,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: null,
      photoUrl: photoUrl,
      parentPhone: parentPhone,
      parentEmail: parentEmail,
      address: address,
      isActive: true,
      enrolledAt: now,
      createdAt: now,
      updatedAt: now,
    );

    return await _repository.createStudent(student);
  }
}
