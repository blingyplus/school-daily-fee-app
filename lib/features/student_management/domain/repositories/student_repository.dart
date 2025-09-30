import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/student_fee_config.dart';

abstract class StudentRepository {
  Future<List<Student>> getStudents(String schoolId);
  Future<Student?> getStudentById(String id);
  Future<Student?> getStudentByStudentId(String schoolId, String studentId);
  Future<List<Student>> searchStudents(String schoolId, String query);
  Future<List<Student>> getStudentsByClass(String classId);
  Future<Student> createStudent(Student student);
  Future<Student> updateStudent(Student student);
  Future<void> deleteStudent(String id);
  Future<StudentFeeConfig?> getStudentFeeConfig(String studentId);
  Future<StudentFeeConfig> createStudentFeeConfig(StudentFeeConfig config);
  Future<StudentFeeConfig> updateStudentFeeConfig(StudentFeeConfig config);
}
