import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../../../../shared/data/models/class_model.dart';
import '../../../../shared/domain/entities/student.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';

class AddStudentPage extends StatefulWidget {
  final String schoolId;
  final Student? student;
  final bool isEditing;

  const AddStudentPage({
    super.key,
    required this.schoolId,
    this.student,
    this.isEditing = false,
  });

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedClassId;
  List<ClassModel> _classes = [];
  bool _isLoadingClasses = true;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    if (widget.isEditing && widget.student != null) {
      _populateForm(widget.student!);
    }
  }

  Future<void> _loadClasses() async {
    try {
      final database = getIt<Database>();
      final classes = await database.query(
        DatabaseHelper.tableClasses,
        where: 'school_id = ? AND is_active = ?',
        whereArgs: [widget.schoolId, 1],
        orderBy: 'grade_level ASC, section ASC',
      );

      setState(() {
        _classes =
            classes.map((map) => ClassModel.fromSqliteJson(map)).toList();
        _isLoadingClasses = false;
      });
    } catch (e) {
      print('❌ Error loading classes: $e');
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _parentPhoneController.dispose();
    _parentEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateForm(Student student) {
    _firstNameController.text = student.firstName;
    _lastNameController.text = student.lastName;
    _parentPhoneController.text = student.parentPhone ?? '';
    _parentEmailController.text = student.parentEmail ?? '';
    _addressController.text = student.address ?? '';
    _selectedClassId = student.classId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Student' : 'Add Student'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveStudent,
            ),
        ],
      ),
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is StudentOperationSuccess) {
            Navigator.of(context).pop();
          } else if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.largePadding.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Basic Information'),
                SizedBox(height: 16.h),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Class Selection
                _isLoadingClasses
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: _selectedClassId,
                        decoration: const InputDecoration(
                          labelText: 'Class *',
                          border: OutlineInputBorder(),
                          helperText: 'Select the student\'s class',
                        ),
                        items: _classes.map((classModel) {
                          return DropdownMenuItem<String>(
                            value: classModel.id,
                            child: Text(classModel.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClassId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a class';
                          }
                          return null;
                        },
                      ),
                SizedBox(height: 24.h),

                _buildSectionTitle('Contact Information'),
                SizedBox(height: 16.h),

                // Parent Phone
                TextFormField(
                  controller: _parentPhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Phone',
                    border: OutlineInputBorder(),
                    prefixText: '+233 ',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),

                // Parent Email
                TextFormField(
                  controller: _parentEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Parent Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 32.h),

                // Save Button
                if (!widget.isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveStudent,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      child: const Text('Add Student'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.isEditing && widget.student != null) {
      // Update existing student
      final updatedStudent = widget.student!.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        classId: _selectedClassId,
        parentPhone: _parentPhoneController.text.trim().isNotEmpty
            ? _parentPhoneController.text.trim()
            : null,
        parentEmail: _parentEmailController.text.trim().isNotEmpty
            ? _parentEmailController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      context.read<StudentBloc>().add(UpdateStudent(updatedStudent));
    } else {
      // Create new student - student ID will be auto-generated
      context.read<StudentBloc>().add(CreateStudent(
            schoolId: widget.schoolId,
            classId: _selectedClassId!,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            parentPhone: _parentPhoneController.text.trim().isNotEmpty
                ? _parentPhoneController.text.trim()
                : null,
            parentEmail: _parentEmailController.text.trim().isNotEmpty
                ? _parentEmailController.text.trim()
                : null,
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
          ));
    }
  }
}
