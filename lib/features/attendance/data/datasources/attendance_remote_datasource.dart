import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_record_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
      String schoolId, DateTime date);
  Future<List<AttendanceRecordModel>> getAttendanceRecordsByClass(
      String classId, DateTime date);
  Future<AttendanceRecordModel?> getAttendanceRecord(
      String studentId, DateTime date);
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate);
  Future<AttendanceRecordModel> createAttendanceRecord(
      AttendanceRecordModel record);
  Future<AttendanceRecordModel> updateAttendanceRecord(
      AttendanceRecordModel record);
  Future<void> deleteAttendanceRecord(String id);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AttendanceRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecords(
      String schoolId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('attendance_records')
          .select('*')
          .eq('school_id', schoolId)
          .gte('attendance_date', startOfDay.toIso8601String())
          .lt('attendance_date', endOfDay.toIso8601String())
          .order('recorded_at', ascending: false);

      return (response as List)
          .map((json) => AttendanceRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecordsByClass(
      String classId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('attendance_records')
          .select('*')
          .eq('class_id', classId)
          .gte('attendance_date', startOfDay.toIso8601String())
          .lt('attendance_date', endOfDay.toIso8601String())
          .order('recorded_at', ascending: false);

      return (response as List)
          .map((json) => AttendanceRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance records by class: $e');
    }
  }

  @override
  Future<AttendanceRecordModel?> getAttendanceRecord(
      String studentId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('attendance_records')
          .select('*')
          .eq('student_id', studentId)
          .gte('attendance_date', startOfDay.toIso8601String())
          .lt('attendance_date', endOfDay.toIso8601String())
          .maybeSingle();

      if (response != null) {
        return AttendanceRecordModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch attendance record: $e');
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getStudentAttendanceHistory(
      String studentId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('attendance_records')
          .select('*')
          .eq('student_id', studentId)
          .gte('attendance_date', startDate.toIso8601String())
          .lte('attendance_date', endDate.toIso8601String())
          .order('attendance_date', ascending: false);

      return (response as List)
          .map((json) => AttendanceRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch student attendance history: $e');
    }
  }

  @override
  Future<AttendanceRecordModel> createAttendanceRecord(
      AttendanceRecordModel record) async {
    try {
      final response = await _supabaseClient
          .from('attendance_records')
          .insert(record.toJson())
          .select()
          .single();

      return AttendanceRecordModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create attendance record: $e');
    }
  }

  @override
  Future<AttendanceRecordModel> updateAttendanceRecord(
      AttendanceRecordModel record) async {
    try {
      final response = await _supabaseClient
          .from('attendance_records')
          .update(record.toJson())
          .eq('id', record.id)
          .select()
          .single();

      return AttendanceRecordModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update attendance record: $e');
    }
  }

  @override
  Future<void> deleteAttendanceRecord(String id) async {
    try {
      await _supabaseClient.from('attendance_records').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}
