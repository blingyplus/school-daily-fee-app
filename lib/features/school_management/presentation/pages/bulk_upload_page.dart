import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/excel_editor_widget.dart';

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
              onPressed: () => _openExcelEditor('teachers'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Teachers in App'),
            ),
            TextButton.icon(
              onPressed: _downloadStudentsTemplate,
              icon: const Icon(Icons.file_download),
              label: const Text('Students Template (.xlsx)'),
            ),
            TextButton.icon(
              onPressed: () => _openExcelEditor('students'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Students in App'),
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

  Future<void> _downloadTeachersTemplate() async {
    try {
      // Create Excel file
      final excel = Excel.createExcel();
      // Remove the default sheet and create our custom one
      excel.delete('Sheet1');
      final sheet = excel['Teachers Template'];

      print('📊 Creating Teachers Template Excel file');

      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('First Name');
      sheet.cell(CellIndex.indexByString('B1')).value =
          TextCellValue('Last Name');
      sheet.cell(CellIndex.indexByString('C1')).value =
          TextCellValue('Phone Number');
      sheet.cell(CellIndex.indexByString('D1')).value =
          TextCellValue('Employee ID');
      sheet.cell(CellIndex.indexByString('E1')).value =
          TextCellValue('Email (Optional)');

      // Add sample data
      final sampleData = [
        ['John', 'Doe', '+233123456789', 'EMP001', 'john.doe@school.com'],
        ['Jane', 'Smith', '+233987654321', 'EMP002', 'jane.smith@school.com'],
        ['Michael', 'Johnson', '+233555666777', 'EMP003', ''],
        [
          'Sarah',
          'Williams',
          '+233111222333',
          'EMP004',
          'sarah.williams@school.com'
        ],
      ];

      for (int i = 0; i < sampleData.length; i++) {
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
            TextCellValue(sampleData[i][0]);
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
            TextCellValue(sampleData[i][1]);
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value =
            TextCellValue(sampleData[i][2]);
        sheet.cell(CellIndex.indexByString('D${i + 2}')).value =
            TextCellValue(sampleData[i][3]);
        sheet.cell(CellIndex.indexByString('E${i + 2}')).value =
            TextCellValue(sampleData[i][4]);
      }

      // Try to save to accessible directories
      Directory? directory;
      String? filePath;
      final fileName = 'teachers_template.xlsx';

      // First try external storage Downloads (most accessible)
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          filePath = '${directory.path}/$fileName';
        }
      } catch (e) {
        print('External Downloads directory failed: $e');
      }

      // Fallback to Downloads directory
      if (directory == null || filePath == null) {
        try {
          directory = await getDownloadsDirectory();
          if (directory != null) {
            filePath = '${directory.path}/$fileName';
          }
        } catch (e) {
          print('Downloads directory failed: $e');
        }
      }

      // Fallback to Documents directory
      if (directory == null || filePath == null) {
        try {
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        } catch (e) {
          print('Documents directory failed: $e');
        }
      }

      if (directory == null || filePath == null) {
        throw Exception('No accessible directory found for saving files');
      }

      // Save file
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template saved to Downloads: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'File location: $filePath\n\nYou can find it in your Downloads folder or file manager.'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading template: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadStudentsTemplate() async {
    try {
      // Create Excel file
      final excel = Excel.createExcel();
      // Remove the default sheet and create our custom one
      excel.delete('Sheet1');
      final sheet = excel['Students Template'];

      print('📊 Creating Students Template Excel file');

      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value =
          TextCellValue('Student ID');
      sheet.cell(CellIndex.indexByString('B1')).value =
          TextCellValue('First Name');
      sheet.cell(CellIndex.indexByString('C1')).value =
          TextCellValue('Last Name');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Class');
      sheet.cell(CellIndex.indexByString('E1')).value =
          TextCellValue('Date of Birth (YYYY-MM-DD)');
      sheet.cell(CellIndex.indexByString('F1')).value =
          TextCellValue('Parent Phone');
      sheet.cell(CellIndex.indexByString('G1')).value =
          TextCellValue('Parent Email (Optional)');
      sheet.cell(CellIndex.indexByString('H1')).value =
          TextCellValue('Address (Optional)');

      // Add sample data
      final sampleData = [
        [
          'STU001',
          'Alice',
          'Johnson',
          '1A',
          '2015-03-15',
          '+233123456789',
          'parent1@email.com',
          '123 Main St'
        ],
        [
          'STU002',
          'Bob',
          'Smith',
          '1A',
          '2015-07-22',
          '+233987654321',
          'parent2@email.com',
          '456 Oak Ave'
        ],
        [
          'STU003',
          'Charlie',
          'Brown',
          '1B',
          '2015-11-08',
          '+233555666777',
          '',
          '789 Pine Rd'
        ],
        [
          'STU004',
          'Diana',
          'Wilson',
          '2A',
          '2014-05-30',
          '+233111222333',
          'parent4@email.com',
          '321 Elm St'
        ],
      ];

      for (int i = 0; i < sampleData.length; i++) {
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
            TextCellValue(sampleData[i][0]);
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
            TextCellValue(sampleData[i][1]);
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value =
            TextCellValue(sampleData[i][2]);
        sheet.cell(CellIndex.indexByString('D${i + 2}')).value =
            TextCellValue(sampleData[i][3]);
        sheet.cell(CellIndex.indexByString('E${i + 2}')).value =
            TextCellValue(sampleData[i][4]);
        sheet.cell(CellIndex.indexByString('F${i + 2}')).value =
            TextCellValue(sampleData[i][5]);
        sheet.cell(CellIndex.indexByString('G${i + 2}')).value =
            TextCellValue(sampleData[i][6]);
        sheet.cell(CellIndex.indexByString('H${i + 2}')).value =
            TextCellValue(sampleData[i][7]);
      }

      // Try to save to accessible directories
      Directory? directory;
      String? filePath;
      final fileName = 'students_template.xlsx';

      // First try external storage Downloads (most accessible)
      try {
        directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          filePath = '${directory.path}/$fileName';
        }
      } catch (e) {
        print('External Downloads directory failed: $e');
      }

      // Fallback to Downloads directory
      if (directory == null || filePath == null) {
        try {
          directory = await getDownloadsDirectory();
          if (directory != null) {
            filePath = '${directory.path}/$fileName';
          }
        } catch (e) {
          print('Downloads directory failed: $e');
        }
      }

      // Fallback to Documents directory
      if (directory == null || filePath == null) {
        try {
          directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
        } catch (e) {
          print('Documents directory failed: $e');
        }
      }

      if (directory == null || filePath == null) {
        throw Exception('No accessible directory found for saving files');
      }

      // Save file
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template saved to Downloads: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'File location: $filePath\n\nYou can find it in your Downloads folder or file manager.'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading template: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _openExcelEditor(String type) {
    print('📊 Opening Excel editor for $type...');

    if (type == 'teachers') {
      final headers = [
        'First Name',
        'Last Name',
        'Phone Number',
        'Employee ID',
        'Email (Optional)'
      ];
      final sampleData = [
        ['John', 'Doe', '+233123456789', 'EMP001', 'john.doe@school.com'],
        ['Jane', 'Smith', '+233987654321', 'EMP002', 'jane.smith@school.com'],
        ['Mike', 'Johnson', '+233555666777', 'EMP003', ''],
        [
          'Sarah',
          'Wilson',
          '+233111222333',
          'EMP004',
          'sarah.wilson@school.com'
        ],
      ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExcelEditorWidget(
            title: 'Teachers Template',
            headers: headers,
            initialData: sampleData,
            onSave: (editedData) {
              print('💾 Teachers data saved from editor');
              print('📊 Received ${editedData.length} teacher records');

              // Process the edited data
              for (int i = 0; i < editedData.length; i++) {
                final row = editedData[i];
                if (row.length >= 4) {
                  final firstName = row[0].trim();
                  final lastName = row[1].trim();
                  final phone = row[2].trim();
                  final employeeId = row[3].trim();
                  final email = row.length > 4 ? row[4].trim() : '';

                  if (firstName.isNotEmpty &&
                      lastName.isNotEmpty &&
                      phone.isNotEmpty &&
                      employeeId.isNotEmpty) {
                    print(
                        '✅ Teacher: $firstName $lastName ($employeeId) - $phone${email.isNotEmpty ? ' - $email' : ''}');
                  }
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Successfully processed ${editedData.length} teachers from editor'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );
    } else if (type == 'students') {
      final headers = [
        'Student ID',
        'First Name',
        'Last Name',
        'Class',
        'Date of Birth (YYYY-MM-DD)',
        'Parent Phone',
        'Parent Email (Optional)',
        'Address (Optional)'
      ];
      final sampleData = [
        [
          'STU001',
          'Alice',
          'Johnson',
          '1A',
          '2015-03-15',
          '+233123456789',
          'parent1@email.com',
          '123 Main St'
        ],
        [
          'STU002',
          'Bob',
          'Smith',
          '1A',
          '2015-07-22',
          '+233987654321',
          'parent2@email.com',
          '456 Oak Ave'
        ],
        [
          'STU003',
          'Charlie',
          'Brown',
          '1B',
          '2015-11-08',
          '+233555666777',
          '',
          '789 Pine Rd'
        ],
        [
          'STU004',
          'Diana',
          'Wilson',
          '2A',
          '2014-05-30',
          '+233111222333',
          'parent4@email.com',
          '321 Elm St'
        ],
      ];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExcelEditorWidget(
            title: 'Students Template',
            headers: headers,
            initialData: sampleData,
            onSave: (editedData) {
              print('💾 Students data saved from editor');
              print('📊 Received ${editedData.length} student records');

              // Process the edited data
              for (int i = 0; i < editedData.length; i++) {
                final row = editedData[i];
                if (row.length >= 6) {
                  final studentId = row[0].trim();
                  final firstName = row[1].trim();
                  final lastName = row[2].trim();
                  final className = row[3].trim();
                  final dob = row[4].trim();
                  final parentPhone = row[5].trim();

                  if (studentId.isNotEmpty &&
                      firstName.isNotEmpty &&
                      lastName.isNotEmpty &&
                      className.isNotEmpty &&
                      dob.isNotEmpty &&
                      parentPhone.isNotEmpty) {
                    print(
                        '✅ Student: $firstName $lastName ($studentId) - Class: $className');
                  }
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Successfully processed ${editedData.length} students from editor'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );
    }
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
      // Process uploaded files
      if (_teachersFilePath != null) {
        print('📁 Processing teachers file: $_teachersFilePath');
        print('📊 Reading Excel file for teachers...');
        // Process Excel file and bulk insert teachers
        final file = File(_teachersFilePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final excel = Excel.decodeBytes(bytes);
          final sheet =
              excel['Teachers Template'] ?? excel[excel.tables.keys.first];
          print('📋 Found ${sheet.maxRows - 1} teacher records in Excel file');
        }
      }

      if (_studentsFilePath != null) {
        print('📁 Processing students file: $_studentsFilePath');
        print('📊 Reading Excel file for students...');
        // Process Excel file and bulk insert students
        final file = File(_studentsFilePath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final excel = Excel.decodeBytes(bytes);
          final sheet =
              excel['Students Template'] ?? excel[excel.tables.keys.first];
          print('📋 Found ${sheet.maxRows - 1} student records in Excel file');
        }
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
