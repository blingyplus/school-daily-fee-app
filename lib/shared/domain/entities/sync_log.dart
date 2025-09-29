import 'package:equatable/equatable.dart';

enum SyncOperation { insert, update, delete }

enum SyncStatus { pending, syncing, synced, failed }

class SyncLog extends Equatable {
  final String id;
  final String schoolId;
  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final DateTime timestamp;
  final SyncStatus syncStatus;
  final Map<String, dynamic>? conflictData;
  final DateTime createdAt;

  const SyncLog({
    required this.id,
    required this.schoolId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.timestamp,
    required this.syncStatus,
    this.conflictData,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        entityType,
        entityId,
        operation,
        timestamp,
        syncStatus,
        conflictData,
        createdAt,
      ];

  SyncLog copyWith({
    String? id,
    String? schoolId,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    DateTime? timestamp,
    SyncStatus? syncStatus,
    Map<String, dynamic>? conflictData,
    DateTime? createdAt,
  }) {
    return SyncLog(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      conflictData: conflictData ?? this.conflictData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
