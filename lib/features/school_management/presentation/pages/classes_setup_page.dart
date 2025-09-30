import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class ClassesSetupPage extends StatefulWidget {
  final String schoolId;
  final String userId;

  const ClassesSetupPage({
    super.key,
    required this.schoolId,
    required this.userId,
  });

  @override
  State<ClassesSetupPage> createState() => _ClassesSetupPageState();
}

class _ClassesSetupPageState extends State<ClassesSetupPage> {
  final List<Map<String, String>> _classes = [];
  final _formKey = GlobalKey<FormState>();
  final _gradeController = TextEditingController();
  final _sectionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _gradeController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Classes'),
        actions: [
          if (_classes.isNotEmpty)
            TextButton(
              onPressed: _handleSkip,
              child: const Text('Skip for now'),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _classes.isEmpty ? _buildEmptyState() : _buildClassesList(),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.class_,
            size: 40.sp,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Classes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add grade levels and sections for your school',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80.sp,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: 16.h),
          Text(
            'No classes added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap the button below to add your first class',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _classes.length,
      itemBuilder: (context, index) {
        final classItem = _classes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                classItem['grade']!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text('Grade ${classItem['grade']}'),
            subtitle: Text('Section ${classItem['section']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeClass(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton.icon(
            onPressed: _showAddClassDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Class'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 50.h),
            ),
          ),
          if (_classes.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleContinue,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                minimumSize: Size(double.infinity, 50.h),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Continue'),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade Level',
                  hintText: 'e.g., 1, 2, 3, KG',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter grade level';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _sectionController,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  hintText: 'e.g., A, B, C',
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter section';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _gradeController.clear();
              _sectionController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addClass,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addClass() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _classes.add({
          'grade': _gradeController.text.trim(),
          'section': _sectionController.text.trim(),
        });
      });
      _gradeController.clear();
      _sectionController.clear();
      Navigator.pop(context);
    }
  }

  void _removeClass(int index) {
    setState(() {
      _classes.removeAt(index);
    });
  }

  void _handleSkip() {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.dashboard,
      arguments: {
        'role': 'admin',
        'schoolId': widget.schoolId,
        'userId': widget.userId,
      },
    );
  }

  Future<void> _handleContinue() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save classes to database
      print('✅ Saving ${_classes.length} classes');

      // Simulate save
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to fee structure setup
      Navigator.pushReplacementNamed(
        context,
        AppRouter.feeStructureSetup,
        arguments: {
          'schoolId': widget.schoolId,
          'userId': widget.userId,
          'classes': _classes,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
}
