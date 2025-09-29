import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/environment.dart' as env;
import '../../shared/data/datasources/local/database_helper.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  failed,
  conflict,
}

enum SyncDirection {
  upload, // Local to remote
  download, // Remote to local
  bidirectional, // Both directions
}

class SyncResult {
  final SyncStatus status;
  final String? message;
  final int? recordsProcessed;
  final List<SyncConflict>? conflicts;

  SyncResult({
    required this.status,
    this.message,
    this.recordsProcessed,
    this.conflicts,
  });
}

class SyncConflict {
  final String entityType;
  final String entityId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final DateTime localTimestamp;
  final DateTime remoteTimestamp;

  SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    required this.localTimestamp,
    required this.remoteTimestamp,
  });
}

class SyncEngine {
  final SupabaseClient supabaseClient;
  final Database database;
  final Connectivity connectivity;

  StreamController<SyncResult>? _syncController;
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTimestamp;

  SyncEngine({
    required this.supabaseClient,
    required this.database,
    required this.connectivity,
  });

  Stream<SyncResult> get syncStream {
    _syncController ??= StreamController<SyncResult>.broadcast();
    return _syncController!.stream;
  }

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTimestamp => _lastSyncTimestamp;

  /// Initialize the sync engine
  Future<void> initialize() async {
    if (!env.Environment.useSupabase) return;

    // Start periodic sync
    _startPeriodicSync();

    // Listen to connectivity changes
    connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _triggerSync();
      }
    });
  }

  /// Start periodic sync every 5 minutes
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerSync();
    });
  }

  /// Trigger sync if conditions are met
  Future<void> _triggerSync() async {
    if (_isSyncing || !env.Environment.useSupabase) return;

    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    await sync(SyncDirection.bidirectional);
  }

  /// Manual sync trigger
  Future<SyncResult> sync(SyncDirection direction) async {
    if (_isSyncing) {
      return SyncResult(
        status: SyncStatus.failed,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;
    _emitSyncResult(SyncResult(status: SyncStatus.syncing));

    try {
      int totalRecords = 0;
      List<SyncConflict> conflicts = [];

      switch (direction) {
        case SyncDirection.upload:
          totalRecords += await _uploadPendingChanges();
          break;
        case SyncDirection.download:
          totalRecords += await _downloadRemoteChanges();
          break;
        case SyncDirection.bidirectional:
          totalRecords += await _uploadPendingChanges();
          totalRecords += await _downloadRemoteChanges();
          break;
      }

      _lastSyncTimestamp = DateTime.now();

      final result = SyncResult(
        status: SyncStatus.success,
        message: 'Sync completed successfully',
        recordsProcessed: totalRecords,
        conflicts: conflicts.isNotEmpty ? conflicts : null,
      );

      _emitSyncResult(result);
      return result;
    } catch (e) {
      final result = SyncResult(
        status: SyncStatus.failed,
        message: 'Sync failed: $e',
      );
      _emitSyncResult(result);
      return result;
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload pending local changes to remote
  Future<int> _uploadPendingChanges() async {
    int recordsProcessed = 0;

    // Get pending sync records
    final pendingRecords = await database.query(
      DatabaseHelper.tableSyncLog,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );

    for (final record in pendingRecords) {
      try {
        await _uploadRecord(record);
        recordsProcessed++;

        // Mark as synced
        await database.update(
          DatabaseHelper.tableSyncLog,
          {
            'sync_status': 'synced',
            'synced_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      } catch (e) {
        // Mark as failed
        await database.update(
          DatabaseHelper.tableSyncLog,
          {
            'sync_status': 'failed',
          },
          where: 'id = ?',
          whereArgs: [record['id']],
        );
        print('Failed to upload record ${record['id']}: $e');
      }
    }

    return recordsProcessed;
  }

  /// Download remote changes to local
  Future<int> _downloadRemoteChanges() async {
    int recordsProcessed = 0;

    try {
      // Get last sync timestamp
      final lastSync = _lastSyncTimestamp ??
          DateTime.now().subtract(const Duration(days: 30));

      // Download changes for each entity type
      final entityTypes = [
        'attendance_records',
        'fee_collections',
        'students',
        'classes',
        'holidays',
      ];

      for (final entityType in entityTypes) {
        final changes = await _downloadEntityChanges(entityType, lastSync);
        recordsProcessed += changes;
      }
    } catch (e) {
      print('Failed to download remote changes: $e');
    }

    return recordsProcessed;
  }

  /// Download changes for a specific entity type
  Future<int> _downloadEntityChanges(String entityType, DateTime since) async {
    try {
      final response = await supabaseClient
          .from(entityType)
          .select()
          .gte('updated_at', since.toIso8601String());

      int recordsProcessed = 0;

      for (final record in response) {
        await _applyRemoteChange(entityType, record);
        recordsProcessed++;
      }

      return recordsProcessed;
    } catch (e) {
      print('Failed to download $entityType changes: $e');
      return 0;
    }
  }

  /// Apply remote change to local database
  Future<void> _applyRemoteChange(
      String entityType, Map<String, dynamic> record) async {
    final tableName = _getTableName(entityType);
    if (tableName == null) return;

    try {
      // Check if record exists locally
      final existing = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [record['id']],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // Update existing record
        await database.update(
          tableName,
          record,
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      } else {
        // Insert new record
        await database.insert(tableName, record);
      }
    } catch (e) {
      print('Failed to apply remote change for $entityType: $e');
    }
  }

  /// Upload a single record to remote
  Future<void> _uploadRecord(Map<String, dynamic> record) async {
    final entityType = record['entity_type'] as String;
    final operation = record['operation'] as String;
    final entityId = record['entity_id'] as String;

    final tableName = _getTableName(entityType);
    if (tableName == null) return;

    // Get the actual record data
    final recordData = await database.query(
      tableName,
      where: 'id = ?',
      whereArgs: [entityId],
      limit: 1,
    );

    if (recordData.isEmpty) return;

    final data = recordData.first;

    switch (operation) {
      case 'insert':
      case 'update':
        await supabaseClient.from(entityType).upsert(data);
        break;
      case 'delete':
        await supabaseClient.from(entityType).delete().eq('id', entityId);
        break;
    }
  }

  /// Get table name for entity type
  String? _getTableName(String entityType) {
    switch (entityType) {
      case 'attendance_records':
        return DatabaseHelper.tableAttendanceRecords;
      case 'fee_collections':
        return DatabaseHelper.tableFeeCollections;
      case 'students':
        return DatabaseHelper.tableStudents;
      case 'classes':
        return DatabaseHelper.tableClasses;
      case 'holidays':
        return DatabaseHelper.tableHolidays;
      default:
        return null;
    }
  }

  /// Log a sync operation
  Future<void> logSyncOperation({
    required String schoolId,
    required String entityType,
    required String entityId,
    required String operation,
  }) async {
    if (!env.Environment.useSupabase) return;

    try {
      await database.insert(DatabaseHelper.tableSyncLog, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'school_id': schoolId,
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to log sync operation: $e');
    }
  }

  /// Resolve sync conflict
  Future<void> resolveConflict(SyncConflict conflict, bool useLocal) async {
    try {
      if (useLocal) {
        // Use local data, upload to remote
        await supabaseClient
            .from(conflict.entityType)
            .upsert(conflict.localData);
      } else {
        // Use remote data, update local
        final tableName = _getTableName(conflict.entityType);
        if (tableName != null) {
          await database.update(
            tableName,
            conflict.remoteData,
            where: 'id = ?',
            whereArgs: [conflict.entityId],
          );
        }
      }
    } catch (e) {
      print('Failed to resolve conflict: $e');
    }
  }

  /// Emit sync result
  void _emitSyncResult(SyncResult result) {
    _syncController?.add(result);
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncController?.close();
  }
}
