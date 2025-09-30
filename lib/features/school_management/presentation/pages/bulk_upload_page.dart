import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/navigation/app_router.dart';

class BulkUploadPage extends StatefulWidget {
  final String schoolId;
  final String userId;

  const BulkUploadPage({
    super.key,
    required this.schoolId,
    required this.userId,
  });

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  String? _teachersFilePath;
  String? _studentsFilePath;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Upload'),
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              _buildTeachersUploadCard(),
              SizedBox(height: 16.h),
              _buildStudentsUploadCard(),
              SizedBox(height: 32.h),
              _buildTemplatesSection(),
              SizedBox(height: 32.h),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.upload_file,
          size: 64.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Bulk Upload Data',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload teachers and students using Excel files',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTeachersUploadCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teachers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Upload teachers via Excel file',
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
            if (_teachersFilePath != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _teachersFilePath!.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _teachersFilePath = null;
                        });
                      },
                      iconSize: 20.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            OutlinedButton.icon(
              onPressed: () => _pickFile('teachers'),
              icon: const Icon(Icons.upload_file),
              label: Text(
                  _teachersFilePath == null ? 'Choose File' : 'Change File'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Required columns: Phone Number, First Name, Last Name',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsUploadCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.groups,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32.sp,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Upload students via Excel file',
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
            if (_studentsFilePath != null) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _studentsFilePath!.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _studentsFilePath = null;
                        });
                      },
                      iconSize: 20.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            OutlinedButton.icon(
              onPressed: () => _pickFile('students'),
              icon: const Icon(Icons.upload_file),
              label: Text(
                  _studentsFilePath == null ? 'Choose File' : 'Change File'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Required: Student ID, First Name, Last Name, Class, Parent Phone',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesSection() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Download Templates',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextButton.icon(
              onPressed: _downloadTeachersTemplate,
              icon: const Icon(Icons.file_download),
              label: const Text('Teachers Template (.xlsx)'),
            ),
            TextButton.icon(
              onPressed: _downloadStudentsTemplate,
              icon: const Icon(Icons.file_download),
              label: const Text('Students Template (.xlsx)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleContinue,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h),
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
          : Text(_teachersFilePath != null || _studentsFilePath != null
              ? 'Upload & Continue'
              : 'Skip for now'),
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (type == 'teachers') {
            _teachersFilePath = result.files.single.path;
          } else {
            _studentsFilePath = result.files.single.path;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${type == 'teachers' ? 'Teachers' : 'Students'} file selected'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _downloadTeachersTemplate() {
    // TODO: Generate and download template
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template download coming soon'),
      ),
    );
  }

  void _downloadStudentsTemplate() {
    // TODO: Generate and download template
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template download coming soon'),
      ),
    );
  }

  void _handleSkip() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.dashboard,
      (route) => false,
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
      // TODO: Process uploaded files
      if (_teachersFilePath != null) {
        print('📁 Processing teachers file: $_teachersFilePath');
        // Process Excel file and bulk insert teachers
      }

      if (_studentsFilePath != null) {
        print('📁 Processing students file: $_studentsFilePath');
        // Process Excel file and bulk insert students
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Navigate to dashboard - onboarding complete!
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.dashboard,
        (route) => false,
        arguments: {
          'role': 'admin',
          'schoolId': widget.schoolId,
          'userId': widget.userId,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 School setup complete! Welcome to your dashboard.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
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
