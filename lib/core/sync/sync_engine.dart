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
    print('🔄 Initializing sync engine...');
    print('🔧 Environment.useSupabase: ${env.Environment.useSupabase}');

    if (!env.Environment.useSupabase) {
      print(
          '⚠️ Supabase is disabled in environment, sync engine will not start');
      return;
    }

    print('✅ Supabase is enabled, starting sync engine...');

    // Start periodic sync
    _startPeriodicSync();

    // Listen to connectivity changes
    connectivity.onConnectivityChanged.listen((result) {
      print('📡 Connectivity changed: $result');
      if (result != ConnectivityResult.none) {
        print('🔄 Triggering sync due to connectivity change...');
        _triggerSync();
      }
    });

    // Trigger initial sync after a short delay
    Timer(const Duration(seconds: 2), () {
      print('🔄 Triggering initial sync...');
      _triggerSync();
    });

    print('✅ Sync engine initialized successfully');
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

  /// Manual sync trigger with smart verification
  Future<SyncResult> sync(SyncDirection direction,
      {bool verifyFirst = true}) async {
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

      // First, verify sync status if enabled
      if (verifyFirst && env.Environment.useSupabase) {
        print('🔍 Verifying sync status before sync...');
        final resetCount = await verifyAndFixSyncStatus();
        if (resetCount > 0) {
          print('✅ Reset $resetCount records that were missing remotely');
        }
      }

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

    print('🔄 Checking for pending sync records...');

    // Get pending sync records
    final pendingRecords = await database.query(
      DatabaseHelper.tableSyncLog,
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );

    print('📊 Found ${pendingRecords.length} pending sync records');

    // Also check for failed records that we can retry
    final failedRecords = await database.query(
      DatabaseHelper.tableSyncLog,
      where: 'sync_status = ?',
      whereArgs: ['failed'],
    );

    print('📊 Found ${failedRecords.length} failed sync records to retry');

    // Combine pending and failed records for processing
    final recordsToProcess = [...pendingRecords, ...failedRecords];
    print('📊 Total records to process: ${recordsToProcess.length}');

    // Debug: Check all sync records
    final allSyncRecords = await database.query(DatabaseHelper.tableSyncLog);
    print('📊 Total sync records in database: ${allSyncRecords.length}');

    if (allSyncRecords.isNotEmpty) {
      print('📋 Sync records:');
      for (final record in allSyncRecords) {
        print(
            '  - ${record['entity_type']}:${record['entity_id']} (${record['sync_status']})');
      }
    }

    // Sort records by dependency order: users first, then teachers, then school_teachers, then students
    final sortedRecords = _sortRecordsByDependency(recordsToProcess);

    for (final record in sortedRecords) {
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
        // Mark as failed with detailed error information
        await database.update(
          DatabaseHelper.tableSyncLog,
          {
            'sync_status': 'failed',
            'conflict_data': e.toString(), // Store as string instead of Map
          },
          where: 'id = ?',
          whereArgs: [record['id']],
        );

        // Log specific error types for better debugging
        if (e.toString().contains('foreign key constraint')) {
          print(
              '❌ Foreign key constraint violation for record ${record['id']}: $e');
        } else if (e.toString().contains('check constraint')) {
          print('❌ Check constraint violation for record ${record['id']}: $e');
        } else if (e
            .toString()
            .contains('date/time field value out of range')) {
          print('❌ Date format error for record ${record['id']}: $e');
        } else {
          print('❌ Failed to upload record ${record['id']}: $e');
        }
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
        'schools',
        'teachers',
        'admins',
        'school_teachers',
        'classes',
        'students',
        'attendance_records',
        'fee_collections',
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

  /// Upload a single record to remote with smart conflict resolution
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

    final localData = recordData.first;

    switch (operation) {
      case 'insert':
      case 'update':
        // Convert timestamps to ISO format for Supabase
        final supabaseData = _convertTimestampsToIso(localData);

        // Check if record exists remotely and compare timestamps
        final remoteRecord = await supabaseClient
            .from(entityType)
            .select()
            .eq('id', entityId)
            .maybeSingle();

        if (remoteRecord != null) {
          // Record exists remotely, check which is newer
          final localUpdatedAt =
              DateTime.parse(supabaseData['updated_at'] as String);
          final remoteUpdatedAt =
              DateTime.parse(remoteRecord['updated_at'] as String);

          if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
            // Remote is newer, skip upload and update local instead
            print(
                '⚠️ Remote record is newer for $entityType:$entityId, skipping upload');
            await _applyRemoteChange(entityType, remoteRecord);
            return;
          }
        }

        // Handle foreign key dependencies
        if (entityType == 'teachers' && supabaseData.containsKey('user_id')) {
          await _ensureUserExistsInSupabase(supabaseData['user_id'] as String);
        }

        if (entityType == 'school_teachers') {
          if (supabaseData.containsKey('teacher_id')) {
            await _ensureTeacherExistsInSupabase(
                supabaseData['teacher_id'] as String);
          }
          if (supabaseData.containsKey('school_id')) {
            await _ensureSchoolExistsInSupabase(
                supabaseData['school_id'] as String);
          }
        }

        if (entityType == 'admins') {
          if (supabaseData.containsKey('user_id')) {
            await _ensureUserExistsInSupabase(
                supabaseData['user_id'] as String);
          }
          if (supabaseData.containsKey('school_id')) {
            await _ensureSchoolExistsInSupabase(
                supabaseData['school_id'] as String);
          }
        }

        if (entityType == 'students' && supabaseData.containsKey('school_id')) {
          await _ensureSchoolExistsInSupabase(
              supabaseData['school_id'] as String);
        }

        // Upload to remote
        await supabaseClient.from(entityType).upsert(supabaseData);
        print('✅ Uploaded $entityType:$entityId to remote');

        // Log to remote sync_log for tracking across devices (if school_id exists)
        final schoolIdForLog = supabaseData['school_id'] as String? ??
            (entityType == 'schools' ? entityId : null);
        if (schoolIdForLog != null) {
          await _logToRemoteSyncLog(
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            schoolId: schoolIdForLog,
          );
        }
        break;
      case 'delete':
        await supabaseClient.from(entityType).delete().eq('id', entityId);
        break;
    }
  }

  /// Sort records by dependency order to avoid foreign key violations
  List<Map<String, dynamic>> _sortRecordsByDependency(
      List<Map<String, dynamic>> records) {
    // Define dependency order (lower number = higher priority)
    final dependencyOrder = {
      'users': 1,
      'schools': 1,
      'classes': 2,
      'teachers': 3,
      'school_teachers': 4,
      'students': 5,
      'admins': 3,
      'attendance_records': 6,
      'fee_collections': 6,
      'holidays': 2,
    };

    final sortedRecords = List<Map<String, dynamic>>.from(records);
    sortedRecords.sort((a, b) {
      final aOrder = dependencyOrder[a['entity_type']] ?? 999;
      final bOrder = dependencyOrder[b['entity_type']] ?? 999;
      return aOrder.compareTo(bOrder);
    });

    print('📋 Sorted ${sortedRecords.length} records by dependency order');
    for (final record in sortedRecords) {
      final order = dependencyOrder[record['entity_type']] ?? 999;
      print(
          '  - ${record['entity_type']}:${record['entity_id']} (order: $order)');
    }

    return sortedRecords;
  }

  /// Ensure user exists in Supabase before creating dependent records
  Future<void> _ensureUserExistsInSupabase(String userId) async {
    try {
      // Check if user exists in Supabase
      final existingUser = await supabaseClient
          .from('users')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingUser == null) {
        // User doesn't exist in Supabase, get from local database and create
        final localUser = await database.query(
          DatabaseHelper.tableUsers,
          where: 'id = ?',
          whereArgs: [userId],
          limit: 1,
        );

        if (localUser.isNotEmpty) {
          final userData = _convertTimestampsToIso(localUser.first);
          print('📝 Creating user in Supabase: $userId');
          await supabaseClient.from('users').upsert(userData);
          print('✅ Created user in Supabase: $userId');
        }
      }
    } catch (e) {
      print('❌ Error ensuring user exists: $e');
      throw e;
    }
  }

  /// Ensure teacher exists in Supabase before creating school_teachers
  Future<void> _ensureTeacherExistsInSupabase(String teacherId) async {
    try {
      // Check if teacher exists in Supabase
      final existingTeacher = await supabaseClient
          .from('teachers')
          .select('id, user_id')
          .eq('id', teacherId)
          .maybeSingle();

      if (existingTeacher == null) {
        // Teacher doesn't exist, get from local database and create
        final localTeacher = await database.query(
          DatabaseHelper.tableTeachers,
          where: 'id = ?',
          whereArgs: [teacherId],
          limit: 1,
        );

        if (localTeacher.isNotEmpty) {
          // First ensure the user exists
          final userId = localTeacher.first['user_id'] as String;
          await _ensureUserExistsInSupabase(userId);

          // Now create the teacher
          final teacherData = _convertTimestampsToIso(localTeacher.first);
          print('📝 Creating teacher in Supabase: $teacherId');
          await supabaseClient.from('teachers').upsert(teacherData);
          print('✅ Created teacher in Supabase: $teacherId');
        }
      }
    } catch (e) {
      print('❌ Error ensuring teacher exists: $e');
      throw e;
    }
  }

  /// Ensure school exists in Supabase before creating dependent records
  Future<void> _ensureSchoolExistsInSupabase(String schoolId) async {
    try {
      // Check if school exists in Supabase
      final existingSchool = await supabaseClient
          .from('schools')
          .select('id')
          .eq('id', schoolId)
          .maybeSingle();

      if (existingSchool == null) {
        // School doesn't exist, get from local database and create
        final localSchool = await database.query(
          DatabaseHelper.tableSchools,
          where: 'id = ?',
          whereArgs: [schoolId],
          limit: 1,
        );

        if (localSchool.isNotEmpty) {
          final schoolData = _convertTimestampsToIso(localSchool.first);
          print('📝 Creating school in Supabase: $schoolId');
          await supabaseClient.from('schools').upsert(schoolData);
          print('✅ Created school in Supabase: $schoolId');
        }
      }
    } catch (e) {
      print('❌ Error ensuring school exists: $e');
      throw e;
    }
  }

  /// Convert timestamp fields from milliseconds to ISO strings and booleans from integers for Supabase
  Map<String, dynamic> _convertTimestampsToIso(Map<String, dynamic> data) {
    final converted = Map<String, dynamic>.from(data);

    // List of timestamp fields that need conversion
    final timestampFields = [
      'created_at',
      'updated_at',
      'assigned_at',
      'synced_at',
      'subscription_expires_at',
      'attendance_date',
      'payment_date',
      'coverage_start_date',
      'coverage_end_date',
      'collected_at',
      'recorded_at',
      'holiday_date',
      'last_login',
      'otp_expires_at',
      'enrolled_at',
      'valid_from',
      'valid_until',
    ];

    // List of boolean fields that need conversion from integers to booleans
    final booleanFields = [
      'is_active',
      'canteen_enabled',
      'transport_enabled',
    ];

    for (final field in timestampFields) {
      if (converted.containsKey(field) && converted[field] != null) {
        final value = converted[field];
        if (value is int) {
          try {
            // Convert milliseconds to ISO string, but validate the timestamp first
            final dateTime = DateTime.fromMillisecondsSinceEpoch(value);
            // Check if the date is reasonable (not too far in the past or future)
            final now = DateTime.now();
            final minDate = DateTime(1900);
            final maxDate = DateTime(2100);

            if (dateTime.isAfter(minDate) && dateTime.isBefore(maxDate)) {
              converted[field] = dateTime.toIso8601String();
            } else {
              // Use current time if the timestamp is invalid
              converted[field] = now.toIso8601String();
            }
          } catch (e) {
            // Use current time if conversion fails
            converted[field] = DateTime.now().toIso8601String();
          }
        }
      }
    }

    for (final field in booleanFields) {
      if (converted.containsKey(field) && converted[field] != null) {
        final value = converted[field];
        if (value is int) {
          // Convert integer to boolean (1 = true, 0 = false)
          converted[field] = value == 1;
        }
      }
    }

    return converted;
  }

  /// Get table name for entity type
  String? _getTableName(String entityType) {
    switch (entityType) {
      case 'schools':
        return DatabaseHelper.tableSchools;
      case 'teachers':
        return DatabaseHelper.tableTeachers;
      case 'admins':
        return DatabaseHelper.tableAdmins;
      case 'school_teachers':
        return DatabaseHelper.tableSchoolTeachers;
      case 'classes':
        return DatabaseHelper.tableClasses;
      case 'students':
        return DatabaseHelper.tableStudents;
      case 'attendance_records':
        return DatabaseHelper.tableAttendanceRecords;
      case 'fee_collections':
        return DatabaseHelper.tableFeeCollections;
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
    if (!env.Environment.useSupabase) {
      print(
          '⚠️ Supabase disabled, not logging sync operation for $entityType:$entityId');
      return;
    }

    try {
      final syncLogId = DateTime.now().millisecondsSinceEpoch.toString();
      print('📝 Logging sync operation: $entityType:$entityId ($operation)');

      final syncLogData = {
        'id': syncLogId,
        'school_id': schoolId,
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'sync_status': 'pending',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      print('📋 Sync log data: $syncLogData');

      await database.insert(DatabaseHelper.tableSyncLog, syncLogData);

      print('✅ Sync operation logged successfully: $syncLogId');

      // Verify the record was inserted
      final insertedRecord = await database.query(
        DatabaseHelper.tableSyncLog,
        where: 'id = ?',
        whereArgs: [syncLogId],
        limit: 1,
      );

      if (insertedRecord.isNotEmpty) {
        print('✅ Verified sync record inserted: ${insertedRecord.first}');
      } else {
        print('❌ Sync record not found after insertion!');
      }
    } catch (e) {
      print('❌ Failed to log sync operation: $e');
      print('❌ Error details: ${e.toString()}');
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

  /// Clear failed sync records and reset them to pending
  Future<void> resetFailedSyncRecords() async {
    try {
      print('🔄 Resetting failed sync records to pending...');

      final result = await database.update(
        DatabaseHelper.tableSyncLog,
        {
          'sync_status': 'pending',
          'conflict_data': null,
        },
        where: 'sync_status = ?',
        whereArgs: ['failed'],
      );

      print('✅ Reset $result failed sync records to pending status');
    } catch (e) {
      print('❌ Error resetting failed sync records: $e');
    }
  }

  /// Reset all synced records back to pending
  /// This is useful when the remote database has been cleared
  Future<void> resetSyncedRecords() async {
    try {
      print('🔄 Resetting synced records to pending...');

      final result = await database.update(
        DatabaseHelper.tableSyncLog,
        {
          'sync_status': 'pending',
          'synced_at': null,
        },
        where: 'sync_status = ?',
        whereArgs: ['synced'],
      );

      print('✅ Reset $result synced records to pending status');
      print(
          '💡 Trigger a manual sync to re-upload all data to the remote database');
    } catch (e) {
      print('❌ Error resetting synced records: $e');
    }
  }

  /// Reset all sync records (synced, failed, and pending) back to pending
  /// This is useful when you want to completely re-sync everything
  Future<void> resetAllSyncRecords() async {
    try {
      print('🔄 Resetting all sync records to pending...');

      final result = await database.update(
        DatabaseHelper.tableSyncLog,
        {
          'sync_status': 'pending',
          'synced_at': null,
          'conflict_data': null,
        },
      );

      print('✅ Reset $result sync records to pending status');
      print(
          '💡 Trigger a manual sync to re-upload all data to the remote database');
    } catch (e) {
      print('❌ Error resetting all sync records: $e');
    }
  }

  /// Log sync operation to remote sync_log table
  Future<void> _logToRemoteSyncLog({
    required String entityType,
    required String entityId,
    required String operation,
    required String schoolId,
  }) async {
    if (!env.Environment.useSupabase || schoolId.isEmpty) return;

    try {
      final syncLogData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString() +
            '_' +
            entityId.substring(0, 8),
        'school_id': schoolId,
        'entity_type': entityType,
        'entity_id': entityId,
        'operation': operation,
        'timestamp': DateTime.now().toIso8601String(),
        'sync_status': 'synced',
        'synced_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabaseClient.from('sync_log').upsert(syncLogData);
      print('📝 Logged to remote sync_log: $entityType:$entityId');
    } catch (e) {
      // Don't fail the sync if remote logging fails
      print('⚠️ Failed to log to remote sync_log: $e');
    }
  }

  /// Verify sync status against remote database and reset missing records
  /// This checks which records are actually synced remotely
  Future<int> verifyAndFixSyncStatus() async {
    if (!env.Environment.useSupabase) {
      print('⚠️ Supabase disabled, skipping sync verification');
      return 0;
    }

    try {
      print('🔍 Verifying sync status against remote database...');

      // Get all local sync records marked as 'synced'
      final localSyncedRecords = await database.query(
        DatabaseHelper.tableSyncLog,
        where: 'sync_status = ?',
        whereArgs: ['synced'],
      );

      print(
          '📊 Found ${localSyncedRecords.length} locally synced records to verify');

      int resetCount = 0;

      // Check each record against remote database
      for (final localRecord in localSyncedRecords) {
        final entityType = localRecord['entity_type'] as String;
        final entityId = localRecord['entity_id'] as String;

        // Check if this entity actually exists in the remote table
        try {
          final remoteEntity = await supabaseClient
              .from(entityType)
              .select('id')
              .eq('id', entityId)
              .maybeSingle();

          if (remoteEntity == null) {
            // Entity doesn't exist remotely, reset to pending
            print(
                '❌ Entity not found remotely: $entityType:$entityId - resetting to pending');

            await database.update(
              DatabaseHelper.tableSyncLog,
              {
                'sync_status': 'pending',
                'synced_at': null,
              },
              where: 'id = ?',
              whereArgs: [localRecord['id']],
            );

            resetCount++;
          }
        } catch (e) {
          // If there's an error checking, reset to pending to be safe
          print(
              '⚠️ Error checking $entityType:$entityId - resetting to pending: $e');
          await database.update(
            DatabaseHelper.tableSyncLog,
            {
              'sync_status': 'pending',
              'synced_at': null,
            },
            where: 'id = ?',
            whereArgs: [localRecord['id']],
          );
          resetCount++;
        }
      }

      print('✅ Verification complete: $resetCount records reset to pending');
      return resetCount;
    } catch (e) {
      print('❌ Error verifying sync status: $e');
      return 0;
    }
  }

  /// Fix data issues before sync
  Future<void> fixDataIssues() async {
    try {
      print('🔧 Fixing data issues...');

      // Fix role constraint violations in school_teachers
      final schoolTeacherResult = await database.update(
        DatabaseHelper.tableSchoolTeachers,
        {
          'role': 'staff', // Change 'teacher' to 'staff'
        },
        where: 'role = ?',
        whereArgs: ['teacher'],
      );

      if (schoolTeacherResult > 0) {
        print('✅ Fixed $schoolTeacherResult school_teacher role constraints');
      }

      // Fix date format issues in students (replace invalid dates with current date)
      final minValidDate = DateTime(2000).millisecondsSinceEpoch;
      final maxValidDate = DateTime(2030).millisecondsSinceEpoch;

      // Get students with invalid dates
      final studentsWithInvalidDates = await database.query(
        DatabaseHelper.tableStudents,
        where: 'date_of_birth < ? OR date_of_birth > ?',
        whereArgs: [minValidDate, maxValidDate],
      );

      for (final student in studentsWithInvalidDates) {
        await database.update(
          DatabaseHelper.tableStudents,
          {
            'date_of_birth':
                DateTime(2010).millisecondsSinceEpoch, // Default to 2010
          },
          where: 'id = ?',
          whereArgs: [student['id']],
        );
      }
    } catch (e) {
      print('❌ Error fixing data issues: $e');
    }
  }

  /// Debug method to check database state
  Future<void> debugDatabaseState() async {
    try {
      print('🔍 Debugging database state...');

      // Check sync log table
      final syncLogRecords = await database.query(DatabaseHelper.tableSyncLog);
      print('📊 Sync log records: ${syncLogRecords.length}');

      // Check users table
      final userRecords = await database.query(DatabaseHelper.tableUsers);
      print('📊 User records: ${userRecords.length}');

      // Check teachers table
      final teacherRecords = await database.query(DatabaseHelper.tableTeachers);
      print('📊 Teacher records: ${teacherRecords.length}');

      // Check students table
      final studentRecords = await database.query(DatabaseHelper.tableStudents);
      print('📊 Student records: ${studentRecords.length}');

      // Check classes table
      final classRecords = await database.query(DatabaseHelper.tableClasses);
      print('📊 Class records: ${classRecords.length}');

      // Check school_teachers table
      final schoolTeacherRecords =
          await database.query(DatabaseHelper.tableSchoolTeachers);
      print('📊 School teacher records: ${schoolTeacherRecords.length}');

      if (syncLogRecords.isNotEmpty) {
        print('📋 Sync log details:');
        for (final record in syncLogRecords) {
          print(
              '  - ID: ${record['id']}, Type: ${record['entity_type']}, Status: ${record['sync_status']}');
        }
      }
    } catch (e) {
      print('❌ Error debugging database state: $e');
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
