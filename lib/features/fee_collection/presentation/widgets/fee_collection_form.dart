import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/domain/entities/fee_collection.dart';
import '../bloc/fee_collection_bloc.dart';
import '../bloc/fee_collection_event.dart';
import '../bloc/fee_collection_state.dart';

class FeeCollectionForm extends StatefulWidget {
  final String schoolId;
  final DateTime paymentDate;
  final VoidCallback onFeeCollected;

  const FeeCollectionForm({
    super.key,
    required this.schoolId,
    required this.paymentDate,
    required this.onFeeCollected,
  });

  @override
  State<FeeCollectionForm> createState() => _FeeCollectionFormState();
}

class _FeeCollectionFormState extends State<FeeCollectionForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  FeeType _selectedFeeType = FeeType.canteen;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  DateTime _coverageStartDate = DateTime.now();
  DateTime _coverageEndDate = DateTime.now();
  String _receiptNumber = '';

  @override
  void initState() {
    super.initState();
    _generateReceiptNumber();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generateReceiptNumber() {
    context.read<FeeCollectionBloc>().add(const GenerateReceiptNumber());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeeCollectionBloc, FeeCollectionState>(
      listener: (context, state) {
        if (state is ReceiptNumberGenerated) {
          setState(() {
            _receiptNumber = state.receiptNumber;
          });
        } else if (state is FeeCollectionOperationSuccess) {
          widget.onFeeCollected();
        } else if (state is FeeCollectionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Student Information'),
              SizedBox(height: 16.h),

              // Student ID
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Student ID is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              _buildSectionTitle('Fee Information'),
              SizedBox(height: 16.h),

              // Fee Type
              DropdownButtonFormField<FeeType>(
                value: _selectedFeeType,
                decoration: const InputDecoration(
                  labelText: 'Fee Type *',
                  border: OutlineInputBorder(),
                ),
                items: FeeType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedFeeType = value;
                    });
                  }
                },
              ),
              SizedBox(height: 16.h),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                  prefixText: '₵ ',
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
              ),
              SizedBox(height: 16.h),

              // Coverage Dates
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectCoverageStartDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Coverage Start Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _formatDate(_coverageStartDate),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: InkWell(
                      onTap: _selectCoverageEndDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Coverage End Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _formatDate(_coverageEndDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              _buildSectionTitle('Payment Information'),
              SizedBox(height: 16.h),

              // Payment Method
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method *',
                  border: OutlineInputBorder(),
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
              ),
              SizedBox(height: 16.h),

              // Receipt Number
              TextFormField(
                initialValue: _receiptNumber,
                decoration: const InputDecoration(
                  labelText: 'Receipt Number',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: null, // Will be handled by the bloc
                  ),
                ),
                readOnly: true,
              ),
              SizedBox(height: 16.h),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 32.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Collect Fee'),
                ),
              ),
            ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectCoverageStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _coverageStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _coverageStartDate = picked;
        if (_coverageEndDate.isBefore(picked)) {
          _coverageEndDate = picked;
        }
      });
    }
  }

  Future<void> _selectCoverageEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _coverageEndDate,
      firstDate: _coverageStartDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _coverageEndDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // TODO: Get current user ID for collectedBy
    const collectedBy = 'current-user-id';

    context.read<FeeCollectionBloc>().add(CollectFee(
          schoolId: widget.schoolId,
          studentId: _studentIdController.text.trim(),
          collectedBy: collectedBy,
          feeType: _selectedFeeType,
          amountPaid: double.parse(_amountController.text.trim()),
          paymentDate: widget.paymentDate,
          coverageStartDate: _coverageStartDate,
          coverageEndDate: _coverageEndDate,
          paymentMethod: _selectedPaymentMethod,
          receiptNumber: _receiptNumber,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        ));
  }
}
