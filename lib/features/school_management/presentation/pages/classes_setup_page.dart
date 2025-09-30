import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';

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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddClassDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Class'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showBulkUploadDialog,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Bulk Upload'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                ),
              ),
            ],
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

  void _showBulkUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Upload Classes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload a CSV file with your classes. The file should have the following columns:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              '• Grade Level (e.g., 1, 2, 3, KG)\n'
              '• Section (e.g., A, B, C)',
              style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickCsvFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select CSV File'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _showTemplateContent,
            child: const Text('View Template'),
          ),
          TextButton(
            onPressed: _downloadTemplate,
            child: const Text('Download Template'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCsvFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          final csvContent = String.fromCharCodes(file.bytes!);
          await _processCsvContent(csvContent);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _processCsvContent(String csvContent) async {
    try {
      final lines = csvContent.split('\n');
      final newClasses = <Map<String, String>>[];

      // Skip header row if it exists
      final startIndex = lines.first.toLowerCase().contains('grade') ? 1 : 0;

      for (int i = startIndex; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final columns = line.split(',').map((e) => e.trim()).toList();
        if (columns.length >= 2) {
          final grade = columns[0].replaceAll('"', '');
          final section = columns[1].replaceAll('"', '');

          if (grade.isNotEmpty && section.isNotEmpty) {
            // Check for duplicates
            final isDuplicate = _classes.any(
                (cls) => cls['grade'] == grade && cls['section'] == section);

            if (!isDuplicate) {
              newClasses.add({
                'grade': grade,
                'section': section,
              });
            }
          }
        }
      }

      if (newClasses.isNotEmpty) {
        setState(() {
          _classes.addAll(newClasses);
        });

        if (mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully added ${newClasses.length} classes'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid classes found in the CSV file'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing CSV: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showTemplateContent() {
    const csvContent = '''Grade Level,Section
1,A
1,B
2,A
2,B
3,A
3,B
KG,A
KG,B''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Classes Template'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this content and save it as a CSV file:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SelectableText(
                  csvContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Copy the content above\n'
                '2. Open a text editor (Notepad, etc.)\n'
                '3. Paste the content\n'
                '4. Save as "classes.csv"\n'
                '5. Upload the file back to the app',
                style: TextStyle(fontSize: 12),
              ),
            ],
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

  Future<void> _downloadTemplate() async {
    try {
      // Create Excel file
      final excelFile = excel.Excel.createExcel();
      final sheet = excelFile['Classes Template'];

      // Add headers
      sheet.cell(excel.CellIndex.indexByString('A1')).value =
          excel.TextCellValue('Grade Level');
      sheet.cell(excel.CellIndex.indexByString('B1')).value =
          excel.TextCellValue('Section');

      // Add sample data
      final sampleData = [
        ['1', 'A'],
        ['1', 'B'],
        ['2', 'A'],
        ['2', 'B'],
        ['3', 'A'],
        ['3', 'B'],
        ['KG', 'A'],
        ['KG', 'B'],
      ];

      for (int i = 0; i < sampleData.length; i++) {
        sheet.cell(excel.CellIndex.indexByString('A${i + 2}')).value =
            excel.TextCellValue(sampleData[i][0]);
        sheet.cell(excel.CellIndex.indexByString('B${i + 2}')).value =
            excel.TextCellValue(sampleData[i][1]);
      }

      // Try multiple directory options
      Directory? directory;
      String? filePath;

      // First try Downloads directory
      try {
        directory = await getDownloadsDirectory();
        if (directory != null) {
          final fileName =
              'classes_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
          filePath = '${directory.path}/$fileName';
        }
      } catch (e) {
        print('Downloads directory failed: $e');
      }

      // Fallback to app documents directory
      if (directory == null) {
        try {
          directory = await getApplicationDocumentsDirectory();
          final fileName =
              'classes_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
          filePath = '${directory.path}/$fileName';
        } catch (e) {
          print('Documents directory failed: $e');
        }
      }

      // Fallback to external storage
      if (directory == null) {
        try {
          directory = Directory('/storage/emulated/0/Download');
          if (await directory.exists()) {
            final fileName =
                'classes_template_${DateTime.now().millisecondsSinceEpoch}.xlsx';
            filePath = '${directory.path}/$fileName';
          }
        } catch (e) {
          print('External storage failed: $e');
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
              content: Text('Template saved to: ${directory.path}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Show Path',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('File saved at: $filePath'),
                      duration: const Duration(seconds: 3),
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
