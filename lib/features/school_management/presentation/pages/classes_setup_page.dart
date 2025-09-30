import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/excel_editor_widget.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../../../shared/data/datasources/local/database_helper.dart';
import '../../../../shared/data/models/class_model.dart';

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
  void initState() {
    super.initState();
    _loadExistingClasses();
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingClasses() async {
    try {
      print('📋 Loading existing classes for school: ${widget.schoolId}');
      final database = getIt<Database>();

      final classes = await database.query(
        DatabaseHelper.tableClasses,
        where: 'school_id = ?',
        whereArgs: [widget.schoolId],
        orderBy: 'grade_level ASC, section ASC',
      );

      if (classes.isNotEmpty) {
        setState(() {
          _classes.clear();
          for (final classData in classes) {
            _classes.add({
              'grade': classData['grade_level'] as String,
              'section': classData['section'] as String,
            });
          }
        });
        print('✅ Loaded ${_classes.length} existing classes');
      } else {
        print('📋 No existing classes found');
      }
    } catch (e) {
      print('❌ Error loading existing classes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Classes'),
        actions: [
          Tooltip(
            message:
                'Add Classes\n\nAdd grade levels and sections for your school. You can add classes manually, import from Excel, or use the in-app editor.',
            child: IconButton(
              onPressed: () {
                // Show the same tooltip content in a dialog for better visibility
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          Icons.class_,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        const Text('Add Classes'),
                      ],
                    ),
                    content: const Text(
                      'Add grade levels and sections for your school. You can add classes manually, import from Excel, or use the in-app editor.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
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
            title: Text('${classItem['grade']}'),
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
        title: const Text('Add Multiple Classes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how you want to add multiple classes:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Primary option - Edit in App
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _openExcelEditor();
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit in App'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Secondary options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadTemplate();
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickExcelFile();
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload File'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickExcelFile() async {
    try {
      print('📁 Starting Excel file picker for classes...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name.toLowerCase();

        print('📄 Selected file: $fileName');

        if (fileName.endsWith('.xlsx')) {
          // Process Excel file
          print('📊 Processing Excel file for classes...');
          await _processExcelFile(file);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select an Excel (.xlsx) file'),
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
      } else {
        print('❌ No file selected');
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
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

  Future<void> _processExcelFile(PlatformFile file) async {
    try {
      print('📊 Processing Excel file: ${file.name}');
      if (file.bytes == null) {
        throw Exception('File is empty');
      }

      // Create a temporary file to read the Excel data
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_classes.xlsx');
      await tempFile.writeAsBytes(file.bytes!);
      print('📁 Created temporary file: ${tempFile.path}');

      // Read Excel file
      final excelFile = excel.Excel.decodeBytes(file.bytes!);
      print('📋 Available sheets: ${excelFile.tables.keys.toList()}');

      final sheet = excelFile['Classes Template'] ??
          excelFile[excelFile.tables.keys.first];

      print('📊 Using sheet: ${excelFile.tables.keys.first}');
      print('📋 Total rows in sheet: ${sheet.maxRows}');

      final newClasses = <Map<String, String>>[];

      // Skip header row and process data
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];
        if (row.length < 2) continue;

        final grade = row[0]?.value?.toString().trim() ?? '';
        final section = row[1]?.value?.toString().trim() ?? '';

        if (grade.isNotEmpty && section.isNotEmpty) {
          // Check for duplicates
          final isDuplicate = _classes
              .any((cls) => cls['grade'] == grade && cls['section'] == section);

          if (!isDuplicate) {
            newClasses.add({
              'grade': grade,
              'section': section,
            });
            print('✅ Added class: $grade $section');
          } else {
            print('⚠️ Duplicate class skipped: $grade $section');
          }
        }
      }

      print('📊 Total new classes found: ${newClasses.length}');

      if (newClasses.isEmpty) {
        print('❌ No valid class data found in Excel file');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No valid class data found in Excel file'),
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
        return;
      }

      // Add new classes
      setState(() {
        _classes.addAll(newClasses);
      });

      print('✅ Successfully imported ${newClasses.length} classes from Excel');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully imported ${newClasses.length} classes from Excel'),
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

      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
        print('🗑️ Cleaned up temporary file');
      }
    } catch (e) {
      print('❌ Error processing Excel file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing Excel file: $e'),
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
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No valid classes found in the CSV file'),
              backgroundColor: Colors.orange,
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
            content: Text('Error processing CSV: $e'),
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

  void _showTemplateContent() {
    const csvContent =
        '''Grade Level,Section
Nursery 1,A
Nursery 2,A
KG 1,A
KG 2,A
BS 1,A
BS 1,B
BS 2,A
BS 3,A
BS 3,B
BS 4,A
BS 4,B
BS 5,A
BS 5,B
BS 6,A
BS 6,B
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Classes Template',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Copy this content and save it as a CSV file:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]!
                        : Colors.grey[300]!,
                  ),
                ),
                child: SelectableText(
                  csvContent,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Copy the content above\n'
                '2. Open a text editor (Notepad, etc.)\n'
                '3. Paste the content\n'
                '4. Save as "classes.csv"\n'
                '5. Upload the file back to the app',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
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
      print('📊 Creating Classes Template Excel file...');
      // Create Excel file
      final excelFile = excel.Excel.createExcel();
      // Remove the default sheet and create our custom one
      excelFile.delete('Sheet1');
      final sheet = excelFile['Classes Template'];

      print('📋 Created sheet: Classes Template');

      // Add headers
      sheet.cell(excel.CellIndex.indexByString('A1')).value =
          excel.TextCellValue('Grade Level');
      sheet.cell(excel.CellIndex.indexByString('B1')).value =
          excel.TextCellValue('Section');

      // Add sample data with comprehensive grade levels
      final sampleData = [
        ['Creche', ''],
        ['Nursery 1', 'A'],
        ['Nursery 1', 'B'],
        ['Nursery 2', 'A'],
        ['Nursery 2', 'B'],
        ['KG 1', 'A'],
        ['KG 1', 'B'],
        ['KG 2', 'A'],
        ['KG 2', 'B'],
        ['BS 1', 'A'],
        ['BS 1', 'B'],
        ['BS 2', 'A'],
        ['BS 2', 'B'],
        ['BS 3', 'A'],
        ['BS 3', 'B'],
        ['BS 4', 'A'],
        ['BS 4', 'B'],
        ['BS 5', 'A'],
        ['BS 5', 'B'],
        ['BS 6', 'A'],
        ['BS 6', 'B'],
      ];

      for (int i = 0; i < sampleData.length; i++) {
        sheet.cell(excel.CellIndex.indexByString('A${i + 2}')).value =
            excel.TextCellValue(sampleData[i][0]);
        sheet.cell(excel.CellIndex.indexByString('B${i + 2}')).value =
            excel.TextCellValue(sampleData[i][1]);
      }

      // Try to save to accessible directories
      Directory? directory;
      String? filePath;
      final fileName = 'classes_template.xlsx';

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
      print('💾 Saving template to: $filePath');
      final fileBytes = excelFile.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        print('✅ Template saved successfully: $fileName');

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
      } else {
        print('❌ Failed to save template - no bytes generated');
      }
    } catch (e) {
      print('❌ Error downloading template: $e');
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

  void _openExcelEditor() {
    print('📊 Opening Excel editor for classes...');

    // Create sample data for the editor
    final headers = ['Grade Level', 'Section'];
    final sampleData = [
      ['Creche', ''],
      ['Nursery 1', 'A'],
      ['Nursery 1', 'B'],
      ['Nursery 2', 'A'],
      ['Nursery 2', 'B'],
      ['KG 1', 'A'],
      ['KG 1', 'B'],
      ['KG 2', 'A'],
      ['KG 2', 'B'],
      ['BS 1', 'A'],
      ['BS 1', 'B'],
      ['BS 2', 'A'],
      ['BS 2', 'B'],
      ['BS 3', 'A'],
      ['BS 3', 'B'],
      ['BS 4', 'A'],
      ['BS 4', 'B'],
      ['BS 5', 'A'],
      ['BS 5', 'B'],
      ['BS 6', 'A'],
      ['BS 6', 'B'],
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExcelEditorWidget(
          title: 'Classes Template',
          headers: headers,
          initialData: sampleData,
          onSave: (editedData) {
            print('💾 Classes data saved from editor');
            print('📊 Received ${editedData.length} rows');

            // Process the edited data and add to classes
            final newClasses = <Map<String, String>>[];

            for (int i = 0; i < editedData.length; i++) {
              final row = editedData[i];
              if (row.length >= 2) {
                final grade = row[0].trim();
                final section = row[1].trim();

                if (grade.isNotEmpty && section.isNotEmpty) {
                  // Check for duplicates
                  final isDuplicate = _classes.any((cls) =>
                      cls['grade'] == grade && cls['section'] == section);

                  if (!isDuplicate) {
                    newClasses.add({
                      'grade': grade,
                      'section': section,
                    });
                    print('✅ Added class: $grade $section');
                  } else {
                    print(
                        '⚠️ Duplicate class skipped: Grade $grade, Section $section');
                  }
                }
              }
            }

            if (newClasses.isNotEmpty) {
              setState(() {
                _classes.addAll(newClasses);
              });

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Successfully added ${newClasses.length} classes from editor'),
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
            }

            // Close the Excel editor and return to the classes setup page
            Navigator.pop(context);
          },
        ),
      ),
    );
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
      // Save classes to database
      print('💾 Saving ${_classes.length} classes to database...');
      await _saveClassesToDatabase();
      print('✅ Classes saved successfully');

      if (!mounted) return;

      // Navigate to fee structure setup
      print('🚀 Navigating to fee structure setup...');
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
      print('❌ Error in _handleContinue: $e');
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

  Future<void> _saveClassesToDatabase() async {
    try {
      final database = getIt<Database>();
      final syncEngine = getIt<SyncEngine>();
      final uuid = const Uuid();
      final now = DateTime.now();
      final currentYear = now.year;

      for (int i = 0; i < _classes.length; i++) {
        final cls = _classes[i];
        final grade = cls['grade'] as String;
        final section = cls['section'] as String;

        print('📋 Saving class ${i + 1}: $grade $section');

        final classModel = ClassModel(
          id: uuid.v4(),
          schoolId: widget.schoolId,
          name: '$grade $section',
          gradeLevel: grade,
          section: section,
          academicYear: currentYear,
          isActive: true,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        );

        // Save to local database first
        await database.insert(
          DatabaseHelper.tableClasses,
          classModel.toSqliteJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Log sync operation for this class
        await syncEngine.logSyncOperation(
          schoolId: widget.schoolId,
          entityType: 'classes',
          entityId: classModel.id,
          operation: 'insert',
        );

        // Sync to Supabase in background (no immediate sync for bulk operations)
        // Data is logged for sync and will be uploaded by the sync engine

        print('✅ Class saved: ${classModel.name}');
      }

      print('✅ All ${_classes.length} classes saved to database');
    } catch (e) {
      print('❌ Error saving classes: $e');
      throw Exception('Failed to save classes: $e');
    }
  }
}
