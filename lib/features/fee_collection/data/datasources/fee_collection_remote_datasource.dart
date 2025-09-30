import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_collection_model.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

abstract class FeeCollectionRemoteDataSource {
  Future<List<FeeCollectionModel>> getFeeCollections(
      String schoolId, DateTime date);
  Future<List<FeeCollectionModel>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate);
  Future<List<FeeCollectionModel>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date);
  Future<FeeCollectionModel?> getFeeCollectionById(String id);
  Future<FeeCollectionModel> createFeeCollection(FeeCollectionModel collection);
  Future<FeeCollectionModel> updateFeeCollection(FeeCollectionModel collection);
  Future<void> deleteFeeCollection(String id);
}

class FeeCollectionRemoteDataSourceImpl
    implements FeeCollectionRemoteDataSource {
  final SupabaseClient _supabaseClient;

  FeeCollectionRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<FeeCollectionModel>> getFeeCollections(
      String schoolId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('fee_collections')
          .select('*')
          .eq('school_id', schoolId)
          .gte('payment_date', startOfDay.toIso8601String())
          .lt('payment_date', endOfDay.toIso8601String())
          .order('collected_at', ascending: false);

      return (response as List)
          .map((json) => FeeCollectionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fee collections: $e');
    }
  }

  @override
  Future<List<FeeCollectionModel>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('fee_collections')
          .select('*')
          .eq('student_id', studentId)
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String())
          .order('payment_date', ascending: false);

      return (response as List)
          .map((json) => FeeCollectionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fee collections by student: $e');
    }
  }

  @override
  Future<List<FeeCollectionModel>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('fee_collections')
          .select('*')
          .eq('school_id', schoolId)
          .eq('fee_type', feeType.name)
          .gte('payment_date', startOfDay.toIso8601String())
          .lt('payment_date', endOfDay.toIso8601String())
          .order('collected_at', ascending: false);

      return (response as List)
          .map((json) => FeeCollectionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fee collections by type: $e');
    }
  }

  @override
  Future<FeeCollectionModel?> getFeeCollectionById(String id) async {
    try {
      final response = await _supabaseClient
          .from('fee_collections')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        return FeeCollectionModel.fromJson(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch fee collection: $e');
    }
  }

  @override
  Future<FeeCollectionModel> createFeeCollection(
      FeeCollectionModel collection) async {
    try {
      final response = await _supabaseClient
          .from('fee_collections')
          .insert(collection.toJson())
          .select()
          .single();

      return FeeCollectionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create fee collection: $e');
    }
  }

  @override
  Future<FeeCollectionModel> updateFeeCollection(
      FeeCollectionModel collection) async {
    try {
      final response = await _supabaseClient
          .from('fee_collections')
          .update(collection.toJson())
          .eq('id', collection.id)
          .select()
          .single();

      return FeeCollectionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update fee collection: $e');
    }
  }

  @override
  Future<void> deleteFeeCollection(String id) async {
    try {
      await _supabaseClient.from('fee_collections').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete fee collection: $e');
    }
  }
}
