import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/domain/entities/student.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_state.dart';
import 'add_student_page.dart';

class StudentDetailsPage extends StatefulWidget {
  final Student student;
  final String schoolId;

  const StudentDetailsPage({
    super.key,
    required this.student,
    required this.schoolId,
  });

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AddStudentPage(
        schoolId: widget.schoolId,
        student: widget.student,
        isEditing: true,
      ),
    );
  }
}
