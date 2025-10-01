import 'package:json_annotation/json_annotation.dart';
import '../../../../shared/domain/entities/attendance_record.dart';

part 'attendance_record_model.g.dart';

@JsonSerializable()
class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.schoolId,
    required super.studentId,
    required super.classId,
    required super.recordedBy,
    required super.attendanceDate,
    required super.status,
    super.notes,
    required super.recordedAt,
    super.syncedAt,
    required super.syncStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordModelToJson(this);

  factory AttendanceRecordModel.fromEntity(AttendanceRecord record) {
    return AttendanceRecordModel(
      id: record.id,
      schoolId: record.schoolId,
      studentId: record.studentId,
      classId: record.classId,
      recordedBy: record.recordedBy,
      attendanceDate: record.attendanceDate,
      status: record.status,
      notes: record.notes,
      recordedAt: record.recordedAt,
      syncedAt: record.syncedAt,
      syncStatus: record.syncStatus,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }

  AttendanceRecord toEntity() {
    return AttendanceRecord(
      id: id,
      schoolId: schoolId,
      studentId: studentId,
      classId: classId,
      recordedBy: recordedBy,
      attendanceDate: attendanceDate,
      status: status,
      notes: notes,
      recordedAt: recordedAt,
      syncedAt: syncedAt,
      syncStatus: syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: map['id'].toString(),
      schoolId: map['school_id'].toString(),
      studentId: map['student_id'].toString(),
      classId: map['class_id'].toString(),
      recordedBy: map['recorded_by'].toString(),
      attendanceDate: DateTime.fromMillisecondsSinceEpoch(
          _parseInt(map['attendance_date'])),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.present,
      ),
      notes: map['notes']?.toString(),
      recordedAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['recorded_at'])),
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(_parseInt(map['synced_at']))
          : null,
      syncStatus: map['sync_status'].toString(),
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['created_at'])),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(_parseInt(map['updated_at'])),
    );
  }

  /// Helper method to safely parse integer values from database
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId,
      'student_id': studentId,
      'class_id': classId,
      'recorded_by': recordedBy,
      'attendance_date': attendanceDate.millisecondsSinceEpoch,
      'status': status.name,
      'notes': notes,
      'recorded_at': recordedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
