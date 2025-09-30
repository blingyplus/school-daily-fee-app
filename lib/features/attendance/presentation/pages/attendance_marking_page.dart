import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/attendance_student_card.dart';
import '../widgets/attendance_date_selector.dart';

class AttendanceMarkingPage extends StatefulWidget {
  final String schoolId;
  final String classId;
  final String className;

  const AttendanceMarkingPage({
    super.key,
    required this.schoolId,
    required this.classId,
    required this.className,
  });

  @override
  State<AttendanceMarkingPage> createState() => _AttendanceMarkingPageState();
}

class _AttendanceMarkingPageState extends State<AttendanceMarkingPage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, AttendanceStatus> _attendanceMap = {};
  final Map<String, String> _notesMap = {};
  List<Student> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // TODO: Load students for the class
    // For now, we'll use mock data
    setState(() {
      _students = [
        Student(
          id: '1',
          schoolId: widget.schoolId,
          classId: widget.classId,
          studentId: 'ST001',
          firstName: 'John',
          lastName: 'Doe',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Student(
          id: '2',
          schoolId: widget.schoolId,
          classId: widget.classId,
          studentId: 'ST002',
          firstName: 'Jane',
          lastName: 'Smith',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Student(
          id: '3',
          schoolId: widget.schoolId,
          classId: widget.classId,
          studentId: 'ST003',
          firstName: 'Mike',
          lastName: 'Johnson',
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance - ${widget.className}'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date Selector
                AttendanceDateSelector(
                  selectedDate: _selectedDate,
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                    _loadAttendanceForDate(date);
                  },
                ),

                // Quick Actions
                _buildQuickActions(),

                // Students List
                Expanded(
                  child: BlocConsumer<AttendanceBloc, AttendanceState>(
                    listener: (context, state) {
                      if (state is AttendanceError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else if (state is AttendanceOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AttendanceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final attendanceStatus = _attendanceMap[student.id] ??
                              AttendanceStatus.present;
                          final notes = _notesMap[student.id] ?? '';

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: AttendanceStudentCard(
                              student: student,
                              attendanceStatus: attendanceStatus,
                              notes: notes,
                              onStatusChanged: (status) {
                                setState(() {
                                  _attendanceMap[student.id] = status;
                                });
                              },
                              onNotesChanged: (notes) {
                                setState(() {
                                  _notesMap[student.id] = notes;
                                });
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding.w,
        vertical: AppConstants.smallPadding.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAllPresent(),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark All Present'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _markAllAbsent(),
              icon: const Icon(Icons.cancel),
              label: const Text('Mark All Absent'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _markAllPresent() {
    setState(() {
      for (final student in _students) {
        _attendanceMap[student.id] = AttendanceStatus.present;
      }
    });
  }

  void _markAllAbsent() {
    setState(() {
      for (final student in _students) {
        _attendanceMap[student.id] = AttendanceStatus.absent;
      }
    });
  }

  void _loadAttendanceForDate(DateTime date) {
    // TODO: Load existing attendance records for the date
    // This would typically fetch from the database
  }

  void _saveAttendance() {
    // TODO: Get current user ID for recordedBy
    const recordedBy = 'current-user-id';

    for (final student in _students) {
      final status = _attendanceMap[student.id] ?? AttendanceStatus.present;
      final notes = _notesMap[student.id];

      context.read<AttendanceBloc>().add(MarkAttendance(
            schoolId: widget.schoolId,
            studentId: student.id,
            classId: widget.classId,
            recordedBy: recordedBy,
            attendanceDate: _selectedDate,
            status: status,
            notes: notes,
          ));
    }
  }
}
