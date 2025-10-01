import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../../../../shared/domain/entities/student.dart';
import '../../../../shared/domain/entities/student_fee_config.dart';
import '../../../student_management/presentation/bloc/student_bloc.dart';
import '../../../student_management/presentation/bloc/student_event.dart';
import '../../../student_management/presentation/bloc/student_state.dart';
import '../../../student_management/domain/usecases/get_student_fee_config_usecase.dart';
import '../../../student_management/domain/usecases/update_student_fee_config_usecase.dart';
import '../../../../core/di/injection.dart';
import '../bloc/fee_collection_bloc.dart';
import '../bloc/fee_collection_event.dart';
import '../bloc/fee_collection_state.dart';

/// Streamlined Fee Collection Form
/// - Search and select student
/// - Show fee types as pills with configured amounts
/// - Enter total amount given
/// - Auto-disburse based on configuration
class StreamlinedFeeCollectionForm extends StatefulWidget {
  final String schoolId;
  final DateTime paymentDate;
  final VoidCallback onFeeCollected;
  final bool autoFocusSearch;

  const StreamlinedFeeCollectionForm({
    super.key,
    required this.schoolId,
    required this.paymentDate,
    required this.onFeeCollected,
    this.autoFocusSearch = false,
  });

  @override
  State<StreamlinedFeeCollectionForm> createState() =>
      _StreamlinedFeeCollectionFormState();
}

class _StreamlinedFeeCollectionFormState
    extends State<StreamlinedFeeCollectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _amountGivenController = TextEditingController();
  final _notesController = TextEditingController();
  final _getStudentFeeConfigUseCase = getIt<GetStudentFeeConfigUseCase>();
  final _updateStudentFeeConfigUseCase = getIt<UpdateStudentFeeConfigUseCase>();

  Student? _selectedStudent;
  String? _studentFeeConfigId;
  bool _isLoadingFeeConfig = false;
  bool _showAdvancedOptions = false;
  int _numberOfDays = 1;

  // Fee amounts (editable)
  double _canteenAmount = 0.0;
  double _transportAmount = 0.0;
  bool _canteenEnabled = false;
  bool _transportEnabled = false;

  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  String _receiptNumber = '';
  List<Student> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _generateReceiptNumber();
    if (widget.autoFocusSearch) {
      // Delay focus to allow widget to build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _amountGivenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateReceiptNumber() {
    context.read<FeeCollectionBloc>().add(const GenerateReceiptNumber());
  }

  Future<void> _loadStudentFeeConfig(String studentId) async {
    setState(() {
      _isLoadingFeeConfig = true;
    });

    try {
      final feeConfig = await _getStudentFeeConfigUseCase(studentId);
      setState(() {
        if (feeConfig != null) {
          _studentFeeConfigId = feeConfig.id;
          _canteenAmount = feeConfig.canteenDailyFee;
          _transportAmount = feeConfig.transportDailyFee;
          _canteenEnabled = feeConfig.canteenEnabled;
          _transportEnabled = feeConfig.transportEnabled;
          // Auto-fill amount given with total
          _amountGivenController.text = _totalFeeAmount.toStringAsFixed(2);
        }
        _isLoadingFeeConfig = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFeeConfig = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load fee configuration: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _showSearchResults = true;
    });

    context.read<StudentBloc>().add(SearchStudents(
          widget.schoolId,
          query,
        ));
  }

  void _onStudentSelected(Student student) {
    setState(() {
      _selectedStudent = student;
      _searchController.text = '${student.studentId} - ${student.fullName}';
      _showSearchResults = false;
      _searchResults = [];
    });
    _loadStudentFeeConfig(student.id);
  }

  void _clearSelection() {
    setState(() {
      _selectedStudent = null;
      _searchController.clear();
      _canteenAmount = 0.0;
      _transportAmount = 0.0;
      _canteenEnabled = false;
      _transportEnabled = false;
      _amountGivenController.clear();
    });
  }

  double get _totalFeeAmount {
    double total = 0.0;
    if (_canteenEnabled) total += _canteenAmount;
    if (_transportEnabled) total += _transportAmount;
    return total * _numberOfDays;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FeeCollectionBloc, FeeCollectionState>(
          listener: (context, state) {
            if (state is ReceiptNumberGenerated) {
              setState(() {
                _receiptNumber = state.receiptNumber;
              });
            } else if (state is FeeCollectionOperationSuccess) {
              widget.onFeeCollected();
              _clearSelection();
            } else if (state is FeeCollectionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentLoaded) {
              setState(() {
                _searchResults = state.students;
              });
            }
          },
        ),
      ],
      child: Column(
        children: [
          // Scrollable Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.defaultPadding.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Search
                    _buildStudentSearch(),
                    SizedBox(height: 16.h),

                    // Selected Student Info & Fee Config
                    if (_selectedStudent != null) ...[
                      _buildSelectedStudentCard(),
                      SizedBox(height: 16.h),

                      // Fee Configuration Pills
                      if (!_isLoadingFeeConfig) ...[
                        _buildFeeConfigPills(),
                        SizedBox(height: 12.h),
                        _buildDaysSelector(),
                        SizedBox(height: 8.h),
                        _buildTotalFeeDisplay(),
                        SizedBox(height: 16.h),
                      ] else
                        const Center(child: CircularProgressIndicator()),

                      // Amount Given
                      _buildAmountGivenField(),
                      SizedBox(height: 16.h),

                      // Advanced Options (Collapsible)
                      _buildAdvancedOptionsSection(),
                      SizedBox(height: 16.h),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Collect Button at Bottom (visible only when student selected)
          if (_selectedStudent != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppConstants.defaultPadding.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Collect Fee - ₵ ${_totalFeeAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            labelText: 'Search by Student ID or Name',
            hintText: 'Type to search...',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _selectedStudent != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSelection,
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          enabled: _selectedStudent == null,
          validator: (value) {
            if (_selectedStudent == null) {
              return 'Please select a student';
            }
            return null;
          },
        ),
        if (_showSearchResults && _searchResults.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(maxHeight: 250.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final student = _searchResults[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      student.firstName[0].toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student.fullName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${student.studentId}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () => _onStudentSelected(student),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAdvancedOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _showAdvancedOptions = !_showAdvancedOptions;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  _showAdvancedOptions ? Icons.expand_less : Icons.expand_more,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Advanced Options',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  _showAdvancedOptions ? 'Hide' : 'Show',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showAdvancedOptions) ...[
          SizedBox(height: 16.h),

          // Payment Method
          _buildPaymentMethodDropdown(),
          SizedBox(height: 16.h),

          // Receipt Number
          _buildReceiptNumberField(),
          SizedBox(height: 16.h),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedStudentCard() {
    final student = _selectedStudent!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                student.firstName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Student ID: ${student.studentId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (student.parentPhone != null)
                    Text(
                      'Parent: ${student.parentPhone}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeConfigPills() {
    return Row(
      children: [
        // Canteen Fee Pill
        Expanded(
          child: _buildCompactFeeTypePill(
            label: 'Canteen',
            amount: _canteenAmount,
            enabled: _canteenEnabled,
            color: Colors.orange,
            icon: Icons.restaurant,
            onToggle: (enabled) {
              setState(() {
                _canteenEnabled = enabled;
                _amountGivenController.text =
                    _totalFeeAmount.toStringAsFixed(2);
              });
            },
            onAmountChanged: (amount) {
              setState(() {
                _canteenAmount = amount;
              });
            },
          ),
        ),
        SizedBox(width: 12.w),
        // Transport Fee Pill
        Expanded(
          child: _buildCompactFeeTypePill(
            label: 'Transport',
            amount: _transportAmount,
            enabled: _transportEnabled,
            color: Colors.blue,
            icon: Icons.directions_bus,
            onToggle: (enabled) {
              setState(() {
                _transportEnabled = enabled;
                _amountGivenController.text =
                    _totalFeeAmount.toStringAsFixed(2);
              });
            },
            onAmountChanged: (amount) {
              setState(() {
                _transportAmount = amount;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactFeeTypePill({
    required String label,
    required double amount,
    required bool enabled,
    required Color color,
    required IconData icon,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onAmountChanged,
  }) {
    final amountController =
        TextEditingController(text: amount.toStringAsFixed(2));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: enabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        border: Border.all(
          color: enabled ? color : Colors.grey.shade400,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  onToggle(!enabled);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enabled ? Icons.check_circle : Icons.circle_outlined,
                      color: enabled ? color : Colors.grey,
                      size: 20.sp,
                    ),
                    SizedBox(width: 6.w),
                    Icon(icon,
                        color: enabled ? color : Colors.grey, size: 18.sp),
                    SizedBox(width: 4.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: enabled ? color : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '₵ ',
                style: TextStyle(
                  color: enabled ? color : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: amountController,
                  enabled: enabled,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: enabled ? color : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: color.withOpacity(0.3)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: color.withOpacity(0.3)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    suffix: Text(
                      '/day',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: enabled ? color : Colors.grey,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    final newAmount = double.tryParse(value);
                    if (newAmount != null && newAmount > 0) {
                      onAmountChanged(newAmount);
                      // Auto-update amount given field
                      _amountGivenController.text =
                          _totalFeeAmount.toStringAsFixed(2);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaysSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Days:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _numberOfDays > 1
                    ? () {
                        setState(() {
                          _numberOfDays--;
                          _amountGivenController.text =
                              _totalFeeAmount.toStringAsFixed(2);
                        });
                      }
                    : null,
                iconSize: 24.sp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '$_numberOfDays',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    _numberOfDays++;
                    _amountGivenController.text =
                        _totalFeeAmount.toStringAsFixed(2);
                  });
                },
                iconSize: 24.sp,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // Quick select buttons
              _buildQuickDayButton(7, '1W'),
              SizedBox(width: 4.w),
              _buildQuickDayButton(14, '2W'),
              SizedBox(width: 4.w),
              _buildQuickDayButton(30, '1M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDayButton(int days, String label) {
    final isSelected = _numberOfDays == days;
    return InkWell(
      onTap: () {
        setState(() {
          _numberOfDays = days;
          _amountGivenController.text = _totalFeeAmount.toStringAsFixed(2);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalFeeDisplay() {
    final dailyTotal = (_canteenEnabled ? _canteenAmount : 0.0) +
        (_transportEnabled ? _transportAmount : 0.0);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Total:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₵ ${dailyTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (_numberOfDays > 1) ...[
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_numberOfDays days × ₵${dailyTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          Divider(height: 16.h, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₵ ${_totalFeeAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountGivenField() {
    return TextFormField(
      controller: _amountGivenController,
      decoration: InputDecoration(
        labelText: 'Amount Given *',
        hintText: 'Enter amount paid by student',
        border: const OutlineInputBorder(),
        prefixText: '₵ ',
        prefixIcon: const Icon(Icons.payments),
        suffixIcon: IconButton(
          icon: const Icon(Icons.auto_fix_high),
          tooltip: 'Fill with total fee',
          onPressed: () {
            _amountGivenController.text = _totalFeeAmount.toStringAsFixed(2);
          },
        ),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Amount is required';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<PaymentMethod>(
      value: _selectedPaymentMethod,
      decoration: const InputDecoration(
        labelText: 'Payment Method',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.payment),
      ),
      items: PaymentMethod.values.map((method) {
        return DropdownMenuItem(
          value: method,
          child: Text(method.name.toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPaymentMethod = value;
          });
        }
      },
    );
  }

  Widget _buildReceiptNumberField() {
    return TextFormField(
      initialValue: _receiptNumber,
      decoration: InputDecoration(
        labelText: 'Receipt Number',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.receipt),
        suffixIcon: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _generateReceiptNumber,
        ),
      ),
      readOnly: true,
    );
  }

  Future<void> _showEditFeeDialog({
    required String label,
    required double amount,
    required bool enabled,
    required Color color,
    required Function(double, bool) onSave,
  }) async {
    final amountController =
        TextEditingController(text: amount.toStringAsFixed(2));
    bool isEnabled = enabled;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit $label Fee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text('Enable $label'),
                value: isEnabled,
                onChanged: (value) {
                  setDialogState(() {
                    isEnabled = value;
                  });
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Daily Fee Amount',
                  prefixText: '₵ ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: isEnabled,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount =
                    double.tryParse(amountController.text) ?? amount;
                onSave(newAmount, isEnabled);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    amountController.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_canteenEnabled && !_transportEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable at least one fee type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amountGiven = double.parse(_amountGivenController.text.trim());

    // Validate amount is sufficient
    if (amountGiven < _totalFeeAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Amount given (₵${amountGiven.toStringAsFixed(2)}) is less than total fee (₵${_totalFeeAmount.toStringAsFixed(2)})',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    // Update student fee config with new amounts
    if (_studentFeeConfigId != null) {
      try {
        final updatedConfig = StudentFeeConfig(
          id: _studentFeeConfigId!,
          studentId: _selectedStudent!.id,
          canteenDailyFee: _canteenAmount,
          transportDailyFee: _transportAmount,
          canteenEnabled: _canteenEnabled,
          transportEnabled: _transportEnabled,
          createdAt: DateTime.now(), // Will be overridden by repository
          updatedAt: DateTime.now(),
        );
        await _updateStudentFeeConfigUseCase(updatedConfig);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fee collected but failed to update config: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }

    // Collect fees for all enabled fee types
    final feeCollections = <Map<String, dynamic>>[];

    if (_canteenEnabled && _canteenAmount > 0) {
      feeCollections.add({
        'feeType': FeeType.canteen,
        'amount': _canteenAmount * _numberOfDays,
      });
    }

    if (_transportEnabled && _transportAmount > 0) {
      feeCollections.add({
        'feeType': FeeType.transport,
        'amount': _transportAmount * _numberOfDays,
      });
    }

    // TODO: Get current user ID for collectedBy
    const collectedBy = 'current-user-id';

    // Submit bulk fee collection
    context.read<FeeCollectionBloc>().add(CollectBulkFee(
          schoolId: widget.schoolId,
          studentId: _selectedStudent!.id,
          collectedBy: collectedBy,
          feeCollections: feeCollections,
          amountGiven: amountGiven,
          paymentDate: widget.paymentDate,
          paymentMethod: _selectedPaymentMethod,
          receiptNumber: _receiptNumber,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        ));
  }
}
