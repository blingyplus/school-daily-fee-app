import 'dart:async';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../models/fee_collection_model.dart';
import '../../../../shared/domain/entities/fee_collection.dart';

abstract class FeeCollectionLocalDataSource {
  Future<List<FeeCollectionModel>> getFeeCollections(
      String schoolId, DateTime date);
  Future<List<FeeCollectionModel>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate);
  Future<List<FeeCollectionModel>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date);
  Future<FeeCollectionModel?> getFeeCollectionById(String id);
  Future<String> createFeeCollection(FeeCollectionModel collection);
  Future<void> updateFeeCollection(FeeCollectionModel collection);
  Future<void> deleteFeeCollection(String id);
  Future<List<FeeCollectionModel>> getPendingSyncRecords();
  Future<String> generateReceiptNumber();
}

class FeeCollectionLocalDataSourceImpl implements FeeCollectionLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FeeCollectionLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<FeeCollectionModel>> getFeeCollections(
      String schoolId, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final maps = await db.query(
      DatabaseHelper.tableFeeCollections,
      where: 'school_id = ? AND payment_date >= ? AND payment_date <= ?',
      whereArgs: [schoolId, startOfDay, endOfDay],
      orderBy: 'collected_at DESC',
    );

    return maps.map((map) => FeeCollectionModel.fromMap(map)).toList();
  }

  @override
  Future<List<FeeCollectionModel>> getFeeCollectionsByStudent(
      String studentId, DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;
    final startTimestamp = startDate.millisecondsSinceEpoch;
    final endTimestamp = endDate.millisecondsSinceEpoch;

    final maps = await db.query(
      DatabaseHelper.tableFeeCollections,
      where: 'student_id = ? AND payment_date >= ? AND payment_date <= ?',
      whereArgs: [studentId, startTimestamp, endTimestamp],
      orderBy: 'payment_date DESC',
    );

    return maps.map((map) => FeeCollectionModel.fromMap(map)).toList();
  }

  @override
  Future<List<FeeCollectionModel>> getFeeCollectionsByType(
      String schoolId, FeeType feeType, DateTime date) async {
    final db = await _databaseHelper.database;
    final startOfDay =
        DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final maps = await db.query(
      DatabaseHelper.tableFeeCollections,
      where:
          'school_id = ? AND fee_type = ? AND payment_date >= ? AND payment_date <= ?',
      whereArgs: [schoolId, feeType.name, startOfDay, endOfDay],
      orderBy: 'collected_at DESC',
    );

    return maps.map((map) => FeeCollectionModel.fromMap(map)).toList();
  }

  @override
  Future<FeeCollectionModel?> getFeeCollectionById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFeeCollections,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return FeeCollectionModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<String> createFeeCollection(FeeCollectionModel collection) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final collectionMap = collection.toMap();
    collectionMap['created_at'] = now;
    collectionMap['updated_at'] = now;
    collectionMap['collected_at'] = now;

    await db.insert(DatabaseHelper.tableFeeCollections, collectionMap);
    return collection.id;
  }

  @override
  Future<void> updateFeeCollection(FeeCollectionModel collection) async {
    final db = await _databaseHelper.database;
    final collectionMap = collection.toMap();
    collectionMap['updated_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      DatabaseHelper.tableFeeCollections,
      collectionMap,
      where: 'id = ?',
      whereArgs: [collection.id],
    );
  }

  @override
  Future<void> deleteFeeCollection(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DatabaseHelper.tableFeeCollections,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<FeeCollectionModel>> getPendingSyncRecords() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      DatabaseHelper.tableFeeCollections,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );

    return maps.map((map) => FeeCollectionModel.fromMap(map)).toList();
  }

  @override
  Future<String> generateReceiptNumber() async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    final datePrefix =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Get the count of receipts for today
    final startOfDay =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = startOfDay + (24 * 60 * 60 * 1000) - 1;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableFeeCollections} WHERE collected_at >= ? AND collected_at <= ?',
      [startOfDay, endOfDay],
    );

    final count = result.first['count'] as int;
    final receiptNumber =
        'RCP$datePrefix${(count + 1).toString().padLeft(4, '0')}';

    return receiptNumber;
  }
}
