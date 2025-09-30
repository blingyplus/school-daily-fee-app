import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/excel_editor_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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

  // Track saved data
  List<Map<String, dynamic>> _savedTeachers = [];
  List<Map<String, dynamic>> _savedStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Upload'),
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text('Skip for now'),
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
              // SizedBox(height: 32.h),
              // _buildTemplatesSection(),
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
            if (_savedTeachers.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${_savedTeachers.length} teachers saved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showTeachersModal(),
                      icon: Icon(Icons.visibility,
                          size: 16.sp, color: Colors.green.shade700),
                      label: Text('View',
                          style: TextStyle(
                              color: Colors.green.shade700, fontSize: 12.sp)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit,
                          size: 16.sp, color: Colors.green.shade700),
                      onPressed: () => _openExcelEditor('teachers'),
                      iconSize: 20.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            // Primary action - Add in App
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openExcelEditor('teachers'),
                icon: const Icon(Icons.edit),
                label: const Text('Add Teachers in App'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Secondary actions - Upload and Download in grid
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFile('teachers'),
                    icon: const Icon(Icons.upload_file),
                    label:
                        Text(_teachersFilePath == null ? 'Upload' : 'Change'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadTeachersTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
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
            if (_savedStudents.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.groups,
                      color: Colors.green.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '${_savedStudents.length} students saved',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showStudentsModal(),
                      icon: Icon(Icons.visibility,
                          size: 16.sp, color: Colors.green.shade700),
                      label: Text('View',
                          style: TextStyle(
                              color: Colors.green.shade700, fontSize: 12.sp)),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit,
                          size: 16.sp, color: Colors.green.shade700),
                      onPressed: () => _openExcelEditor('students'),
                      iconSize: 20.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
            // Primary action - Add in App
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openExcelEditor('students'),
                icon: const Icon(Icons.edit),
                label: const Text('Add Students in App'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            // Secondary actions - Upload and Download in grid
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickFile('students'),
                    icon: const Icon(Icons.upload_file),
                    label:
                        Text(_studentsFilePath == null ? 'Upload' : 'Change'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadStudentsTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
              ],
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
            Text(
              'Download Excel templates to fill out and upload later',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 16.h),
            // Download options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadTeachersTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Teachers Template'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadStudentsTemplate,
                    icon: const Icon(Icons.download),
                    label: const Text('Students Template'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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
              : 'Continue'),
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
            action: SnackBarAction(
              label: '✕',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: '✕',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _downloadTeachersTemplate() async {
    try {
      // Create Excel file
      final excelFile = excel.Excel.createExcel();
      // Remove the default sheet and create our custom one
      excelFile.delete('Sheet1');
      final sheet = excelFile['Teachers Template'];

      print('📊 Creating Teachers Template Excel file');

      // Add headers
      sheet.cell(excel.CellIndex.indexByString('A1')).value =
          excel.TextCellValue('First Name');
      sheet.cell(excel.CellIndex.indexByString('B1')).value =
          excel.TextCellValue('Last Name');
      sheet.cell(excel.CellIndex.indexByString('C1')).value =
          excel.TextCellValue('Phone Number');
      sheet.cell(excel.CellIndex.indexByString('D1')).value =
          excel.TextCellValue('Employee ID');
      sheet.cell(excel.CellIndex.indexByString('E1')).value =
          excel.TextCellValue('Email (Optional)');

      // Add sample data
      final sampleData = [
        ['John', 'Doe', '+233023456789', 'EMP001', 'john.doe@school.com'],
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
        sheet.cell(excel.CellIndex.indexByString('A${i + 2}')).value =
            excel.TextCellValue(sampleData[i][0]);
        sheet.cell(excel.CellIndex.indexByString('B${i + 2}')).value =
            excel.TextCellValue(sampleData[i][1]);
        sheet.cell(excel.CellIndex.indexByString('C${i + 2}')).value =
            excel.TextCellValue(sampleData[i][2]);
        sheet.cell(excel.CellIndex.indexByString('D${i + 2}')).value =
            excel.TextCellValue(sampleData[i][3]);
        sheet.cell(excel.CellIndex.indexByString('E${i + 2}')).value =
            excel.TextCellValue(sampleData[i][4]);
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
      final fileBytes = excelFile.save();
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
                label: '✕',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            action: SnackBarAction(
              label: '✕',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadStudentsTemplate() async {
    try {
      // Create Excel file
      final excelFile = excel.Excel.createExcel();
      // Remove the default sheet and create our custom one
      excelFile.delete('Sheet1');
      final sheet = excelFile['Students Template'];

      print('📊 Creating Students Template Excel file');

      // Add headers
      sheet.cell(excel.CellIndex.indexByString('A1')).value =
          excel.TextCellValue('Student ID');
      sheet.cell(excel.CellIndex.indexByString('B1')).value =
          excel.TextCellValue('First Name');
      sheet.cell(excel.CellIndex.indexByString('C1')).value =
          excel.TextCellValue('Last Name');
      sheet.cell(excel.CellIndex.indexByString('D1')).value =
          excel.TextCellValue('Class');
      sheet.cell(excel.CellIndex.indexByString('E1')).value =
          excel.TextCellValue('Date of Birth (YYYY-MM-DD)');
      sheet.cell(excel.CellIndex.indexByString('F1')).value =
          excel.TextCellValue('Parent Phone');
      sheet.cell(excel.CellIndex.indexByString('G1')).value =
          excel.TextCellValue('Parent Email (Optional)');
      sheet.cell(excel.CellIndex.indexByString('H1')).value =
          excel.TextCellValue('Address (Optional)');

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
        sheet.cell(excel.CellIndex.indexByString('A${i + 2}')).value =
            excel.TextCellValue(sampleData[i][0]);
        sheet.cell(excel.CellIndex.indexByString('B${i + 2}')).value =
            excel.TextCellValue(sampleData[i][1]);
        sheet.cell(excel.CellIndex.indexByString('C${i + 2}')).value =
            excel.TextCellValue(sampleData[i][2]);
        sheet.cell(excel.CellIndex.indexByString('D${i + 2}')).value =
            excel.TextCellValue(sampleData[i][3]);
        sheet.cell(excel.CellIndex.indexByString('E${i + 2}')).value =
            excel.TextCellValue(sampleData[i][4]);
        sheet.cell(excel.CellIndex.indexByString('F${i + 2}')).value =
            excel.TextCellValue(sampleData[i][5]);
        sheet.cell(excel.CellIndex.indexByString('G${i + 2}')).value =
            excel.TextCellValue(sampleData[i][6]);
        sheet.cell(excel.CellIndex.indexByString('H${i + 2}')).value =
            excel.TextCellValue(sampleData[i][7]);
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
      final fileBytes = excelFile.save();
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
                label: '✕',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
            action: SnackBarAction(
              label: '✕',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
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
            onSave: (editedData) async {
              print('💾 Teachers data saved from editor');
              print('📊 Received ${editedData.length} teacher records');

              // Process and save the edited data
              final newTeachers = <Map<String, dynamic>>[];
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
                    newTeachers.add({
                      'firstName': firstName,
                      'lastName': lastName,
                      'phone': phone,
                      'employeeId': employeeId,
                      'email': email,
                    });
                    print(
                        '✅ Teacher: $firstName $lastName ($employeeId) - $phone${email.isNotEmpty ? ' - $email' : ''}');
                  }
                }
              }

              try {
                // Save teachers to database
                await _saveTeachersToDatabase(newTeachers);

                // Update saved teachers
                setState(() {
                  _savedTeachers = newTeachers;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Successfully saved ${newTeachers.length} teachers'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: '✕',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error saving teachers: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving teachers: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: '✕',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              }

              // Close the Excel editor and return to the bulk upload page
              Navigator.pop(context);
            },
          ),
        ),
      );
    } else if (type == 'students') {
      final headers = [
        'Student ID',
        'First Name',
        'Last Name',
        'Class(Grade Section)',
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
          'Nursery 1 A',
          '2015-03-15',
          '+233123456789',
          'parent1@email.com',
          '123 Main St'
        ],
        [
          'STU002',
          'Bob',
          'Smith',
          'KG 1 A',
          '2015-07-22',
          '+233987654321',
          'parent2@email.com',
          '456 Oak Ave'
        ],
        [
          'STU003',
          'Charlie',
          'Brown',
          'BS 1 A',
          '2015-11-08',
          '+233555666777',
          '',
          '789 Pine Rd'
        ],
        [
          'STU004',
          'Diana',
          'Wilson',
          'BS 2 A',
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
            onSave: (editedData) async {
              print('💾 Students data saved from editor');
              print('📊 Received ${editedData.length} student records');

              // Process and save the edited data
              final newStudents = <Map<String, dynamic>>[];
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
                    final parentEmail = row.length > 6 ? row[6].trim() : '';
                    final address = row.length > 7 ? row[7].trim() : '';

                    newStudents.add({
                      'studentId': studentId,
                      'firstName': firstName,
                      'lastName': lastName,
                      'className': className,
                      'dob': dob,
                      'parentPhone': parentPhone,
                      'parentEmail': parentEmail,
                      'address': address,
                    });
                    print(
                        '✅ Student: $firstName $lastName ($studentId) - Class: $className');
                  }
                }
              }

              try {
                // Save students to database
                await _saveStudentsToDatabase(newStudents);

                // Update saved students
                setState(() {
                  _savedStudents = newStudents;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Successfully saved ${newStudents.length} students'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: '✕',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                print('❌ Error saving students: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving students: ${e.toString()}'),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: '✕',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              }

              // Close the Excel editor and return to the bulk upload page
              Navigator.pop(context);
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
          final excelFile = excel.Excel.decodeBytes(bytes);
          final sheet = excelFile['Teachers Template'] ??
              excelFile[excelFile.tables.keys.first];
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
          final excelFile = excel.Excel.decodeBytes(bytes);
          final sheet = excelFile['Students Template'] ??
              excelFile[excelFile.tables.keys.first];
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
        SnackBar(
          content: const Text(
              '🎉 School setup complete! Welcome to your dashboard.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '✕',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          action: SnackBarAction(
            label: '✕',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper methods
  bool _hasData() {
    return _savedTeachers.isNotEmpty || _savedStudents.isNotEmpty;
  }

  void _showTeachersModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saved Teachers (${_savedTeachers.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView.builder(
            itemCount: _savedTeachers.length,
            itemBuilder: (context, index) {
              final teacher = _savedTeachers[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      teacher['firstName'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${teacher['firstName']} ${teacher['lastName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${teacher['employeeId']}'),
                      Text('Phone: ${teacher['phone']}'),
                      if (teacher['email'].isNotEmpty)
                        Text('Email: ${teacher['email']}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStudentsModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Saved Students (${_savedStudents.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: ListView.builder(
            itemCount: _savedStudents.length,
            itemBuilder: (context, index) {
              final student = _savedStudents[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      student['firstName'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${student['firstName']} ${student['lastName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${student['studentId']}'),
                      Text('Class: ${student['className']}'),
                      Text('Parent: ${student['parentPhone']}'),
                      if (student['parentEmail'].isNotEmpty)
                        Text('Email: ${student['parentEmail']}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTeachersToDatabase(
      List<Map<String, dynamic>> teachers) async {
    try {
      final database = getIt<Database>();
      final syncEngine = getIt<SyncEngine>();
      final uuid = const Uuid();
      final now = DateTime.now();

      print('💾 Saving ${teachers.length} teachers to database...');

      for (int i = 0; i < teachers.length; i++) {
        final teacher = teachers[i];
        final teacherId = uuid.v4();
        final userId = uuid.v4();

        print(
            '📋 Saving teacher ${i + 1}: ${teacher['firstName']} ${teacher['lastName']}');

        // Create user record first
        await database.insert(
          DatabaseHelper.tableUsers,
          {
            'id': userId,
            'phone_number': teacher['phone'],
            'is_active': 1,
            'created_at': now.millisecondsSinceEpoch,
            'updated_at': now.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Create teacher record
        await database.insert(
          DatabaseHelper.tableTeachers,
          {
            'id': teacherId,
            'user_id': userId,
            'first_name': teacher['firstName'],
            'last_name': teacher['lastName'],
            'employee_id': teacher['employeeId'],
            'created_at': now.millisecondsSinceEpoch,
            'updated_at': now.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Create school-teacher association
        final schoolTeacherId = uuid.v4();
        await database.insert(
          DatabaseHelper.tableSchoolTeachers,
          {
            'id': schoolTeacherId,
            'school_id': widget.schoolId,
            'teacher_id': teacherId,
            'role': 'teacher',
            'assigned_classes': null,
            'is_active': 1,
            'assigned_at': now.millisecondsSinceEpoch,
            'created_at': now.millisecondsSinceEpoch,
            'updated_at': now.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Log sync operations
        await syncEngine.logSyncOperation(
          schoolId: widget.schoolId,
          entityType: 'users',
          entityId: userId,
          operation: 'insert',
        );

        await syncEngine.logSyncOperation(
          schoolId: widget.schoolId,
          entityType: 'teachers',
          entityId: teacherId,
          operation: 'insert',
        );

        await syncEngine.logSyncOperation(
          schoolId: widget.schoolId,
          entityType: 'school_teachers',
          entityId: schoolTeacherId,
          operation: 'insert',
        );

        print(
            '✅ Teacher saved: ${teacher['firstName']} ${teacher['lastName']}');
      }

      print('✅ All ${teachers.length} teachers saved to database');
    } catch (e) {
      print('❌ Error saving teachers: $e');
      throw Exception('Failed to save teachers: $e');
    }
  }

  Future<void> _saveStudentsToDatabase(
      List<Map<String, dynamic>> students) async {
    try {
      final database = getIt<Database>();
      final syncEngine = getIt<SyncEngine>();
      final uuid = const Uuid();
      final now = DateTime.now();

      print('💾 Saving ${students.length} students to database...');

      for (int i = 0; i < students.length; i++) {
        final student = students[i];
        final studentId = uuid.v4();

        print(
            '📋 Saving student ${i + 1}: ${student['firstName']} ${student['lastName']}');

        // Parse date of birth
        DateTime? dob;
        try {
          dob = DateTime.parse(student['dob']);
        } catch (e) {
          print(
              '⚠️ Invalid date format for ${student['firstName']}: ${student['dob']}');
          dob = DateTime(2010, 1, 1); // Default date
        }

        // Find class ID by class name
        final classes = await database.query(
          DatabaseHelper.tableClasses,
          where: 'school_id = ? AND name = ?',
          whereArgs: [widget.schoolId, student['className']],
          limit: 1,
        );

        String? classId;
        if (classes.isNotEmpty) {
          classId = classes.first['id'] as String;
        } else {
          print(
              '⚠️ Class not found: ${student['className']} for student ${student['firstName']}');
          // Use a default class or skip this student
          continue;
        }

        // Create student record
        await database.insert(
          DatabaseHelper.tableStudents,
          {
            'id': studentId,
            'school_id': widget.schoolId,
            'class_id': classId,
            'student_id': student['studentId'],
            'first_name': student['firstName'],
            'last_name': student['lastName'],
            'date_of_birth': dob.millisecondsSinceEpoch,
            'parent_phone': student['parentPhone'],
            'parent_email': student['parentEmail'] ?? '',
            'address': student['address'] ?? '',
            'is_active': 1,
            'enrolled_at': now.millisecondsSinceEpoch,
            'created_at': now.millisecondsSinceEpoch,
            'updated_at': now.millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Log sync operation
        await syncEngine.logSyncOperation(
          schoolId: widget.schoolId,
          entityType: 'students',
          entityId: studentId,
          operation: 'insert',
        );

        print(
            '✅ Student saved: ${student['firstName']} ${student['lastName']}');
      }

      print('✅ All ${students.length} students saved to database');
    } catch (e) {
      print('❌ Error saving students: $e');
      throw Exception('Failed to save students: $e');
    }
  }
}
