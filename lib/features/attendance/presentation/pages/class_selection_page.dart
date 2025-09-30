import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/school_class.dart';
import 'attendance_marking_page.dart';

class ClassSelectionPage extends StatelessWidget {
  final String schoolId;

  const ClassSelectionPage({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Load classes from database
    // For now, we'll use mock data
    final classes = [
      SchoolClass(
        id: '1',
        schoolId: schoolId,
        name: 'Class 1A',
        gradeLevel: '1',
        section: 'A',
        academicYear: 2024,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SchoolClass(
        id: '2',
        schoolId: schoolId,
        name: 'Class 2B',
        gradeLevel: '2',
        section: 'B',
        academicYear: 2024,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SchoolClass(
        id: '3',
        schoolId: schoolId,
        name: 'Class 3C',
        gradeLevel: '3',
        section: 'C',
        academicYear: 2024,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Class'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final schoolClass = classes[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildClassCard(context, schoolClass),
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, SchoolClass schoolClass) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => _navigateToAttendanceMarking(context, schoolClass),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.class_,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolClass.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Grade ${schoolClass.gradeLevel} - Section ${schoolClass.section}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Academic Year: ${schoolClass.academicYear}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAttendanceMarking(
      BuildContext context, SchoolClass schoolClass) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceMarkingPage(
          schoolId: schoolId,
          classId: schoolClass.id,
          className: schoolClass.name,
        ),
      ),
    );
  }
}
