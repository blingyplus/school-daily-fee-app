import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';
import '../models/student_fee_config_model.dart';

abstract class StudentRemoteDataSource {
  Future<List<StudentModel>> getStudents(String schoolId);
  Future<StudentModel?> getStudentById(String id);
  Future<StudentModel?> getStudentByStudentId(
      String schoolId, String studentId);
  Future<List<StudentModel>> searchStudents(String schoolId, String query);
  Future<List<StudentModel>> getStudentsByClass(String classId);
  Future<StudentModel> createStudent(StudentModel student);
  Future<StudentModel> updateStudent(StudentModel student);
  Future<void> deleteStudent(String id);
  Future<StudentFeeConfigModel> createStudentFeeConfig(
      StudentFeeConfigModel config);
  Future<StudentFeeConfigModel?> getStudentFeeConfig(String studentId);
  Future<StudentFeeConfigModel> updateStudentFeeConfig(
      StudentFeeConfigModel config);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final SupabaseClient _supabaseClient;

  StudentRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<StudentModel>> getStudents(String schoolId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('school_id', schoolId)
          .eq('is_active', true)
          .order('first_name')
          .order('last_name');

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  @override
  Future<StudentModel?> getStudentById(String id) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return StudentModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  @override
  Future<StudentModel?> getStudentByStudentId(
      String schoolId, String studentId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('school_id', schoolId)
          .eq('student_id', studentId)
          .maybeSingle();

      if (response != null) {
        return StudentModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch student: $e');
    }
  }

  @override
  Future<List<StudentModel>> searchStudents(
      String schoolId, String query) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('school_id', schoolId)
          .eq('is_active', true)
          .or('first_name.ilike.%$query%,last_name.ilike.%$query%,student_id.ilike.%$query%')
          .order('first_name')
          .order('last_name');

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search students: $e');
    }
  }

  @override
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .select('*')
          .eq('class_id', classId)
          .eq('is_active', true)
          .order('first_name')
          .order('last_name');

      return (response as List)
          .map((json) => StudentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch students by class: $e');
    }
  }

  @override
  Future<StudentModel> createStudent(StudentModel student) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .insert(student.toJson())
          .select()
          .single();

      return StudentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  @override
  Future<StudentModel> updateStudent(StudentModel student) async {
    try {
      final response = await _supabaseClient
          .from('students')
          .update(student.toJson())
          .eq('id', student.id)
          .select()
          .single();

      return StudentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      // Soft delete - mark as inactive
      await _supabaseClient
          .from('students')
          .update({'is_active': false}).eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  @override
  Future<StudentFeeConfigModel> createStudentFeeConfig(
      StudentFeeConfigModel config) async {
    try {
      final response = await _supabaseClient
          .from('student_fee_config')
          .insert(config.toJson())
          .select()
          .single();

      return StudentFeeConfigModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create student fee config: $e');
    }
  }

  @override
  Future<StudentFeeConfigModel?> getStudentFeeConfig(String studentId) async {
    try {
      final response = await _supabaseClient
          .from('student_fee_config')
          .select('*')
          .eq('student_id', studentId)
          .maybeSingle();

      if (response != null) {
        return StudentFeeConfigModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch student fee config: $e');
    }
  }

  @override
  Future<StudentFeeConfigModel> updateStudentFeeConfig(
      StudentFeeConfigModel config) async {
    try {
      final response = await _supabaseClient
          .from('student_fee_config')
          .update(config.toJson())
          .eq('id', config.id)
          .select()
          .single();

      return StudentFeeConfigModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update student fee config: $e');
    }
  }
}
