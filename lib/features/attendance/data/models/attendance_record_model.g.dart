// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceRecordModel _$AttendanceRecordModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceRecordModel(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      studentId: json['studentId'] as String,
      classId: json['classId'] as String,
      recordedBy: json['recordedBy'] as String,
      attendanceDate: DateTime.parse(json['attendanceDate'] as String),
      status: $enumDecode(_$AttendanceStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      syncStatus: json['syncStatus'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AttendanceRecordModelToJson(
        AttendanceRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolId': instance.schoolId,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'recordedBy': instance.recordedBy,
      'attendanceDate': instance.attendanceDate.toIso8601String(),
      'status': _$AttendanceStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$AttendanceStatusEnumMap = {
  AttendanceStatus.present: 'present',
  AttendanceStatus.absent: 'absent',
  AttendanceStatus.late: 'late',
};
