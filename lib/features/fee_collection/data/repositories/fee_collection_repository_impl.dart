import 'dart:async';
import '../../domain/repositories/fee_collection_repository.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../datasources/fee_collection_local_datasource.dart';
import '../datasources/fee_collection_remote_datasource.dart';
import '../models/fee_collection_model.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../core/di/injection.dart';

class FeeCollectionRepositoryImpl implements FeeCollectionRepository {
  final FeeCollectionLocalDataSource _localDataSource;
  final FeeCollectionRemoteDataSource _remoteDataSource;
  final SyncEngine _syncEngine;

  FeeCollectionRepositoryImpl({
    required FeeCollectionLocalDataSource localDataSource,
    required FeeCollectionRemoteDataSource remoteDataSource,
    SyncEngine? syncEngine,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _syncEngine = syncEngine ?? getIt<SyncEngine>();

  @override
  Future<List<FeeCollection>> getFeeCollections(
      String schoolId, DateTime date) async {
    try {
      final localCollections =
          await _localDataSource.getFeeCollections(schoolId, date);
      return localCollections.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get fee collections: $e');
    }
  }

  @override
  Future<List<FeeCollection>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate) async {
    try {
      final localCollections = await _localDataSource
          .getFeeCollectionsByStudent(studentId, startDate, endDate);
      return localCollections.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get fee collections by student: $e');
    }
  }

  @override
  Future<List<FeeCollection>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date) async {
    try {
      final localCollections = await _localDataSource.getFeeCollectionsByType(
          schoolId, feeType, date);
      return localCollections.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get fee collections by type: $e');
    }
  }

  @override
  Future<FeeCollection?> getFeeCollectionById(String id) async {
    try {
      final localCollection = await _localDataSource.getFeeCollectionById(id);
      return localCollection?.toEntity();
    } catch (e) {
      throw Exception('Failed to get fee collection: $e');
    }
  }

  @override
  Future<FeeCollection> createFeeCollection(FeeCollection collection) async {
    try {
      final collectionModel = FeeCollectionModel.fromEntity(collection);

      // Save to local database first
      await _localDataSource.createFeeCollection(collectionModel);

      // Log sync operation for this fee collection
      await _syncEngine.logSyncOperation(
        schoolId: collection.schoolId,
        entityType: 'fee_collections',
        entityId: collection.id,
        operation: 'insert',
      );

      return collection;
    } catch (e) {
      throw Exception('Failed to create fee collection: $e');
    }
  }

  @override
  Future<FeeCollection> updateFeeCollection(FeeCollection collection) async {
    try {
      final collectionModel = FeeCollectionModel.fromEntity(collection);

      // Update local database
      await _localDataSource.updateFeeCollection(collectionModel);

      // Log sync operation for this fee collection
      await _syncEngine.logSyncOperation(
        schoolId: collection.schoolId,
        entityType: 'fee_collections',
        entityId: collection.id,
        operation: 'update',
      );

      return collection;
    } catch (e) {
      throw Exception('Failed to update fee collection: $e');
    }
  }

  @override
  Future<void> deleteFeeCollection(String id) async {
    try {
      // Get fee collection first to get schoolId
      final collection = await _localDataSource.getFeeCollectionById(id);
      if (collection == null) {
        throw Exception('Fee collection not found');
      }

      // Delete from local database
      await _localDataSource.deleteFeeCollection(id);

      // Log sync operation for this fee collection
      await _syncEngine.logSyncOperation(
        schoolId: collection.schoolId,
        entityType: 'fee_collections',
        entityId: id,
        operation: 'delete',
      );
    } catch (e) {
      throw Exception('Failed to delete fee collection: $e');
    }
  }

  @override
  Future<List<FeeCollection>> getPendingSyncRecords() async {
    try {
      final localCollections = await _localDataSource.getPendingSyncRecords();
      return localCollections.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pending sync records: $e');
    }
  }

  @override
  Future<String> generateReceiptNumber() async {
    try {
      return await _localDataSource.generateReceiptNumber();
    } catch (e) {
      throw Exception('Failed to generate receipt number: $e');
    }
  }

  // Remote sync methods (for sync engine)
  Future<List<FeeCollection>> syncFeeCollectionsFromRemote(
      String schoolId, DateTime date) async {
    try {
      final remoteCollections =
          await _remoteDataSource.getFeeCollections(schoolId, date);
      return remoteCollections.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to sync fee collections from remote: $e');
    }
  }

  Future<FeeCollection> syncCreateFeeCollectionToRemote(
      FeeCollection collection) async {
    try {
      final collectionModel = FeeCollectionModel.fromEntity(collection);
      final remoteCollection =
          await _remoteDataSource.createFeeCollection(collectionModel);
      return remoteCollection.toEntity();
    } catch (e) {
      throw Exception('Failed to sync create fee collection to remote: $e');
    }
  }

  Future<FeeCollection> syncUpdateFeeCollectionToRemote(
      FeeCollection collection) async {
    try {
      final collectionModel = FeeCollectionModel.fromEntity(collection);
      final remoteCollection =
          await _remoteDataSource.updateFeeCollection(collectionModel);
      return remoteCollection.toEntity();
    } catch (e) {
      throw Exception('Failed to sync update fee collection to remote: $e');
    }
  }

  Future<void> syncDeleteFeeCollectionToRemote(String id) async {
    try {
      await _remoteDataSource.deleteFeeCollection(id);
    } catch (e) {
      throw Exception('Failed to sync delete fee collection to remote: $e');
    }
  }
}
