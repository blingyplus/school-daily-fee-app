import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final String studentId;

  const StudentDetailsPage({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Implement student details page
    // This would typically fetch student data and display detailed information
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Details'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Student Details Page - Coming Soon'),
      ),
    );
  }
}
