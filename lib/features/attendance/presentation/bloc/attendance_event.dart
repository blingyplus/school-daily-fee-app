import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/attendance_record.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceRecords extends AttendanceEvent {
  final String schoolId;
  final DateTime date;

  const LoadAttendanceRecords(this.schoolId, this.date);

  @override
  List<Object?> get props => [schoolId, date];
}

class LoadClassAttendance extends AttendanceEvent {
  final String classId;
  final DateTime date;

  const LoadClassAttendance(this.classId, this.date);

  @override
  List<Object?> get props => [classId, date];
}

class MarkAttendance extends AttendanceEvent {
  final String schoolId;
  final String studentId;
  final String classId;
  final String recordedBy;
  final DateTime attendanceDate;
  final AttendanceStatus status;
  final String? notes;

  const MarkAttendance({
    required this.schoolId,
    required this.studentId,
    required this.classId,
    required this.recordedBy,
    required this.attendanceDate,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        schoolId,
        studentId,
        classId,
        recordedBy,
        attendanceDate,
        status,
        notes,
      ];
}

class BulkMarkAttendance extends AttendanceEvent {
  final String schoolId;
  final String classId;
  final String recordedBy;
  final DateTime attendanceDate;
  final List<String> studentIds;
  final AttendanceStatus status;
  final String? notes;

  const BulkMarkAttendance({
    required this.schoolId,
    required this.classId,
    required this.recordedBy,
    required this.attendanceDate,
    required this.studentIds,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        schoolId,
        classId,
        recordedBy,
        attendanceDate,
        studentIds,
        status,
        notes,
      ];
}

class UpdateAttendanceRecord extends AttendanceEvent {
  final AttendanceRecord record;

  const UpdateAttendanceRecord(this.record);

  @override
  List<Object?> get props => [record];
}

class DeleteAttendanceRecord extends AttendanceEvent {
  final String id;

  const DeleteAttendanceRecord(this.id);

  @override
  List<Object?> get props => [id];
}
