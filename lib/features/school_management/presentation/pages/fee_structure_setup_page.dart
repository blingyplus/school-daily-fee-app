import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class FeeStructureSetupPage extends StatefulWidget {
  final String schoolId;
  final String userId;

  const FeeStructureSetupPage({
    super.key,
    required this.schoolId,
    required this.userId,
  });

  @override
  State<FeeStructureSetupPage> createState() => _FeeStructureSetupPageState();
}

class _FeeStructureSetupPageState extends State<FeeStructureSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _canteenFeeController = TextEditingController(text: '9.00');
  final _transportFeeController = TextEditingController(text: '15.00');

  bool _canteenEnabled = true;
  bool _transportEnabled = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _canteenFeeController.dispose();
    _transportFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Structure'),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: 32.h),
                _buildCanteenFeeSection(),
                SizedBox(height: 24.h),
                _buildTransportFeeSection(),
                SizedBox(height: 32.h),
                _buildNote(),
                SizedBox(height: 32.h),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.payments_outlined,
          size: 64.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Configure Default Fees',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Set default daily fees for canteen and transportation',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCanteenFeeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Canteen Fee',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _canteenEnabled,
                  onChanged: (value) {
                    setState(() {
                      _canteenEnabled = value;
                    });
                  },
                ),
              ],
            ),
            if (_canteenEnabled) ...[
              SizedBox(height: 16.h),
              TextFormField(
                controller: _canteenFeeController,
                decoration: InputDecoration(
                  labelText: 'Daily Canteen Fee (GHS)',
                  hintText: '9.00',
                  prefixText: 'GHS ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _canteenEnabled
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter canteen fee';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransportFeeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_bus,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Transportation Fee',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: _transportEnabled,
                  onChanged: (value) {
                    setState(() {
                      _transportEnabled = value;
                    });
                  },
                ),
              ],
            ),
            if (_transportEnabled) ...[
              SizedBox(height: 16.h),
              TextFormField(
                controller: _transportFeeController,
                decoration: InputDecoration(
                  labelText: 'Daily Transport Fee (GHS)',
                  hintText: '15.00',
                  prefixText: 'GHS ',
                  helperText:
                      'This is the default fee. You can set custom fees per student',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _transportEnabled
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter transport fee';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      }
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'These are default fees. You can customize fees for individual students later.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
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
          : const Text('Continue'),
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save fee structure to database
      final feeData = {
        'canteen_enabled': _canteenEnabled,
        'canteen_fee':
            _canteenEnabled ? double.parse(_canteenFeeController.text) : 0.0,
        'transport_enabled': _transportEnabled,
        'transport_fee': _transportEnabled
            ? double.parse(_transportFeeController.text)
            : 0.0,
      };

      print('✅ Fee structure: $feeData');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to bulk upload page
      Navigator.pushReplacementNamed(
        context,
        AppRouter.bulkUpload,
        arguments: {
          'schoolId': widget.schoolId,
          'userId': widget.userId,
          'feeStructure': feeData,
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
