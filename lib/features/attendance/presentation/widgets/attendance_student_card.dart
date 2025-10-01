import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/attendance_record.dart';

class AttendanceStudentCard extends StatelessWidget {
  final Student student;
  final AttendanceStatus attendanceStatus;
  final String notes;
  final bool isSelected;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onSelectionChanged;

  const AttendanceStudentCard({
    super.key,
    required this.student,
    required this.attendanceStatus,
    required this.notes,
    this.isSelected = false,
    required this.onStatusChanged,
    required this.onNotesChanged,
    this.onTap,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              // Selection Checkbox (only show when selection mode is enabled)
              if (onSelectionChanged != null) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged!(value ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                SizedBox(width: 8.w),
              ],

              // Student Avatar
              CircleAvatar(
                radius: 18.r,
                backgroundColor:
                    _getStatusColor(attendanceStatus).withOpacity(0.1),
                child: Icon(
                  _getStatusIcon(attendanceStatus),
                  size: 18.sp,
                  color: _getStatusColor(attendanceStatus),
                ),
              ),

              SizedBox(width: 12.w),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      student.studentId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // Status Toggle Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusToggle(
                    context,
                    AttendanceStatus.present,
                    Icons.check_circle,
                    Colors.green,
                  ),
                  SizedBox(width: 4.w),
                  _buildStatusToggle(
                    context,
                    AttendanceStatus.late,
                    Icons.schedule,
                    Colors.orange,
                  ),
                  SizedBox(width: 4.w),
                  _buildStatusToggle(
                    context,
                    AttendanceStatus.absent,
                    Icons.cancel,
                    Colors.red,
                  ),
                ],
              ),

              // Notes Button
              IconButton(
                onPressed: () => _showNotesDialog(context),
                icon: Icon(
                  notes.isNotEmpty ? Icons.note : Icons.note_add,
                  size: 20.sp,
                  color: notes.isNotEmpty
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusToggle(
    BuildContext context,
    AttendanceStatus status,
    IconData icon,
    Color color,
  ) {
    final isSelected = attendanceStatus == status;

    return GestureDetector(
      onTap: () => onStatusChanged(status),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : color,
          size: 16.sp,
        ),
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
    }
  }

  void _showNotesDialog(BuildContext context) {
    final controller = TextEditingController(text: notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notes for ${student.fullName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onNotesChanged(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
