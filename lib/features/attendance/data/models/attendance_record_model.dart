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
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      classId: map['class_id'] as String,
      recordedBy: map['recorded_by'] as String,
      attendanceDate:
          DateTime.fromMillisecondsSinceEpoch(map['attendance_date'] as int),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AttendanceStatus.present,
      ),
      notes: map['notes'] as String?,
      recordedAt:
          DateTime.fromMillisecondsSinceEpoch(map['recorded_at'] as int),
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
      syncStatus: map['sync_status'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
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
