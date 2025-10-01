import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/student.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../widgets/student_card.dart';
import '../widgets/student_search_bar.dart';
import 'add_student_page.dart';
import 'student_details_page.dart';

class StudentsListPage extends StatefulWidget {
  final String schoolId;

  const StudentsListPage({
    super.key,
    required this.schoolId,
  });

  @override
  State<StudentsListPage> createState() => _StudentsListPageState();
}

class _StudentsListPageState extends State<StudentsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load students when page initializes
    context.read<StudentBloc>().add(LoadStudents(widget.schoolId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.defaultPadding.w,
              AppConstants.defaultPadding.h,
              AppConstants.defaultPadding.w,
              AppConstants.smallPadding.h,
            ),
            child: StudentSearchBar(
              controller: _searchController,
              onSearchChanged: (query) {
                if (query.isEmpty) {
                  context.read<StudentBloc>().add(ClearSearch(widget.schoolId));
                } else {
                  context
                      .read<StudentBloc>()
                      .add(SearchStudents(widget.schoolId, query));
                }
              },
            ),
          ),

          // Students List
          Expanded(
            child: BlocConsumer<StudentBloc, StudentState>(
              listener: (context, state) {
                if (state is StudentError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is StudentOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Update the list with new data
                  context
                      .read<StudentBloc>()
                      .add(LoadStudents(widget.schoolId));
                }
              },
              builder: (context, state) {
                if (state is StudentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is StudentError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<StudentBloc>()
                                .add(LoadStudents(widget.schoolId));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is StudentLoaded) {
                  if (state.students.isEmpty) {
                    return _buildEmptyState(context, state.searchQuery);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<StudentBloc>()
                          .add(LoadStudents(widget.schoolId));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding.w,
                        vertical: AppConstants.smallPadding.h,
                      ),
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: StudentCard(
                            student: student,
                            onTap: () => _navigateToStudentDetails(student),
                            onEdit: () => _navigateToEditStudent(student),
                            onDelete: () => _showDeleteDialog(student),
                          ),
                        );
                      },
                    ),
                  );
                }

                return const Center(
                  child: Text('No students found'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddStudent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            searchQuery != null ? Icons.search_off : Icons.people_outline,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            searchQuery != null
                ? 'No students found for "$searchQuery"'
                : 'No students found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            searchQuery != null
                ? 'Try adjusting your search terms'
                : 'Add your first student to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery == null) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _navigateToAddStudent,
              icon: const Icon(Icons.add),
              label: const Text('Add Student'),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToAddStudent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(schoolId: widget.schoolId),
      ),
    );
  }

  void _navigateToEditStudent(student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(
          schoolId: widget.schoolId,
          student: student,
          isEditing: true,
        ),
      ),
    );
  }

  void _navigateToStudentDetails(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentDetailsPage(
          student: student,
          schoolId: widget.schoolId,
        ),
      ),
    );
  }

  void _showDeleteDialog(student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: Text(
            'Are you sure you want to delete ${student.fullName}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<StudentBloc>().add(DeleteStudent(student.id));
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
