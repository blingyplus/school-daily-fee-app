import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/attendance_record.dart';

class AttendanceStudentCard extends StatelessWidget {
  final Student student;
  final AttendanceStatus attendanceStatus;
  final String notes;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final ValueChanged<String> onNotesChanged;

  const AttendanceStudentCard({
    super.key,
    required this.student,
    required this.attendanceStatus,
    required this.notes,
    required this.onStatusChanged,
    required this.onNotesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 20.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'ID: ${student.studentId}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Attendance Status Buttons
            Row(
              children: [
                Expanded(
                  child: _buildStatusButton(
                    context,
                    'Present',
                    AttendanceStatus.present,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    'Absent',
                    AttendanceStatus.absent,
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildStatusButton(
                    context,
                    'Late',
                    AttendanceStatus.late,
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Notes Field
            TextField(
              onChanged: onNotesChanged,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    AttendanceStatus status,
    Color color,
    IconData icon,
  ) {
    final isSelected = attendanceStatus == status;

    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
