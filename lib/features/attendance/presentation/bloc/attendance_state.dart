import 'package:equatable/equatable.dart';
import '../../../../shared/domain/entities/attendance_record.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecord> records;
  final DateTime date;
  final String? classId;

  const AttendanceLoaded({
    required this.records,
    required this.date,
    this.classId,
  });

  @override
  List<Object?> get props => [records, date, classId];

  AttendanceLoaded copyWith({
    List<AttendanceRecord>? records,
    DateTime? date,
    String? classId,
  }) {
    return AttendanceLoaded(
      records: records ?? this.records,
      date: date ?? this.date,
      classId: classId ?? this.classId,
    );
  }
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceOperationSuccess extends AttendanceState {
  final String message;
  final List<AttendanceRecord> records;

  const AttendanceOperationSuccess({
    required this.message,
    required this.records,
  });

  @override
  List<Object?> get props => [message, records];
}

class AttendanceOperationLoading extends AttendanceState {}
