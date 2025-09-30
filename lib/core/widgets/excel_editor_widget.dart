import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:excel/excel.dart' as excel;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExcelEditorWidget extends StatefulWidget {
  final String title;
  final List<List<String>> initialData;
  final List<String> headers;
  final Function(List<List<String>>) onSave;
  final VoidCallback? onCancel;

  const ExcelEditorWidget({
    super.key,
    required this.title,
    required this.initialData,
    required this.headers,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<ExcelEditorWidget> createState() => _ExcelEditorWidgetState();
}

class _ExcelEditorWidgetState extends State<ExcelEditorWidget> {
  late List<List<TextEditingController>> _controllers;
  late List<List<String>> _data;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _data = widget.initialData.map((row) => List<String>.from(row)).toList();

    // Initialize controllers
    _controllers = [];
    for (int i = 0; i < _data.length; i++) {
      _controllers.add([]);
      for (int j = 0; j < _data[i].length; j++) {
        final controller = TextEditingController(text: _data[i][j]);
        controller.addListener(() {
          _hasChanges = true;
          _data[i][j] = controller.text;
        });
        _controllers[i].add(controller);
      }
    }
  }

  @override
  void dispose() {
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      final newRow = List<String>.filled(widget.headers.length, '');
      _data.add(newRow);

      final newControllers = <TextEditingController>[];
      for (int j = 0; j < widget.headers.length; j++) {
        final controller = TextEditingController();
        controller.addListener(() {
          _hasChanges = true;
          _data[_data.length - 1][j] = controller.text;
        });
        newControllers.add(controller);
      }
      _controllers.add(newControllers);
    });
  }

  void _removeRow(int index) {
    if (_data.length > 1) {
      // Keep at least one row
      setState(() {
        for (var controller in _controllers[index]) {
          controller.dispose();
        }
        _controllers.removeAt(index);
        _data.removeAt(index);
        _hasChanges = true;
      });
    }
  }

  void _saveData() {
    print('💾 Saving Excel data...');
    print('📊 Data rows: ${_data.length}');
    for (int i = 0; i < _data.length; i++) {
      print('📋 Row ${i + 1}: ${_data[i].join(', ')}');
    }

    widget.onSave(_data);
    _hasChanges = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _exportToExcel() async {
    try {
      print('📊 Exporting to Excel...');

      // Create Excel file
      final excelFile = excel.Excel.createExcel();
      excelFile.delete('Sheet1');
      final sheet = excelFile[widget.title];

      // Add headers
      for (int j = 0; j < widget.headers.length; j++) {
        sheet
            .cell(excel.CellIndex.indexByString(
                '${String.fromCharCode(65 + j)}1'))
            .value = excel.TextCellValue(widget.headers[j]);
      }

      // Add data
      for (int i = 0; i < _data.length; i++) {
        for (int j = 0; j < _data[i].length; j++) {
          sheet
              .cell(excel.CellIndex.indexByString(
                  '${String.fromCharCode(65 + j)}${i + 2}'))
              .value = excel.TextCellValue(_data[i][j]);
        }
      }

      // Save to downloads
      final directory = await getDownloadsDirectoryLocal();
      if (directory != null) {
        final fileName =
            '${widget.title.toLowerCase().replaceAll(' ', '_')}_edited.xlsx';
        final filePath = '${directory.path}/$fileName';

        final fileBytes = excelFile.save();
        if (fileBytes != null) {
          final file = File(filePath);
          await file.writeAsBytes(fileBytes);

          print('✅ Excel file exported: $fileName');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('📁 File exported to Downloads: $fileName'),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error exporting to Excel: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveData,
              tooltip: 'Save Changes',
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToExcel,
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    '• Tap any cell to edit\n'
                    '• Use + button at bottom to add rows\n'
                    '• Use - button to remove rows\n'
                    '• Save changes or export to Excel when done',
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
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Data table - Excel-like layout
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 8.w,
                  horizontalMargin: 12.w,
                  columns: [
                    DataColumn(
                      label: SizedBox(
                        width: 50.w,
                        child: const Text(''),
                      ),
                    ),
                    ...widget.headers.map((header) => DataColumn(
                          label: SizedBox(
                            width: 120.w,
                            child: Text(
                              header,
                              style: TextStyle(
                                  fontSize: 12.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                  ],
                  rows: [
                    // Data rows
                    ...List.generate(_data.length, (index) {
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 50.w,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red, size: 20),
                                onPressed: _data.length > 1
                                    ? () => _removeRow(index)
                                    : null,
                                tooltip: 'Remove row',
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          ..._data[index].asMap().entries.map((entry) {
                            return DataCell(
                              SizedBox(
                                width: 120.w,
                                height: 32.h,
                                child: TextField(
                                  controller: _controllers[index][entry.key],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    isDense: true,
                                  ),
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                    // Add row button at the bottom
                    DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 50.w,
                            child: IconButton(
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.green, size: 20),
                              onPressed: _addRow,
                              tooltip: 'Add Row',
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        ...widget.headers.map((header) => DataCell(
                              Container(
                                width: 120.w,
                                height: 32.h,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                                child: const Center(
                                  child: Text(''),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom actions
          Container(
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
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportToExcel,
                    icon: const Icon(Icons.download),
                    label: const Text('Export Excel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to get downloads directory
Future<Directory?> getDownloadsDirectoryLocal() async {
  try {
    // Try external storage Downloads first
    final externalDir = Directory('/storage/emulated/0/Download');
    if (await externalDir.exists()) {
      return externalDir;
    }
  } catch (e) {
    print('External Downloads directory failed: $e');
  }

  // Fallback to app documents directory
  try {
    return await getApplicationDocumentsDirectory();
  } catch (e) {
    print('Documents directory failed: $e');
    return null;
  }
}
