import 'package:equatable/equatable.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceRecord extends Equatable {
  final String id;
  final String schoolId;
  final String studentId;
  final String classId;
  final String recordedBy;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final String? notes;
  final DateTime recordedAt;
  final DateTime? syncedAt;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRecord({
    required this.id,
    required this.schoolId,
    required this.studentId,
    required this.classId,
    required this.recordedBy,
    required this.attendanceDate,
    required this.status,
    this.notes,
    required this.recordedAt,
    this.syncedAt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        schoolId,
        studentId,
        classId,
        recordedBy,
        attendanceDate,
        status,
        notes,
        recordedAt,
        syncedAt,
        syncStatus,
        createdAt,
        updatedAt,
      ];

  AttendanceRecord copyWith({
    String? id,
    String? schoolId,
    String? studentId,
    String? classId,
    String? recordedBy,
    DateTime? attendanceDate,
    AttendanceStatus? status,
    String? notes,
    DateTime? recordedAt,
    DateTime? syncedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      recordedBy: recordedBy ?? this.recordedBy,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      recordedAt: recordedAt ?? this.recordedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
