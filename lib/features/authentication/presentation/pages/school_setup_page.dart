import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/school_service.dart';

class SchoolSetupPage extends StatefulWidget {
  final String userId;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  const SchoolSetupPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<SchoolSetupPage> createState() => _SchoolSetupPageState();
}

class _SchoolSetupPageState extends State<SchoolSetupPage> {
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _schoolCodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _schoolNameController.dispose();
    _schoolCodeController.dispose();
    _addressController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your School'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_currentStep == 2 ? 'Complete' : 'Continue'),
                  ),
                  if (_currentStep > 0) ...[
                    SizedBox(width: 12.w),
                    TextButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('School Information'),
              content: _buildSchoolInfoStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Contact Details'),
              content: _buildContactDetailsStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Review & Confirm'),
              content: _buildReviewStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfoStep() {
    return Form(
      key: _step1FormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _schoolNameController,
            decoration: InputDecoration(
              labelText: 'School Name *',
              hintText: 'e.g., St. Mary\'s International School',
              prefixIcon: const Icon(Icons.school),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter school name';
              }
              if (value.trim().length < 3) {
                return 'School name must be at least 3 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _schoolCodeController,
            decoration: InputDecoration(
              labelText: 'School Code *',
              hintText: 'e.g., SMIS2024',
              helperText: 'Teachers will use this code to join your school',
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter school code';
              }
              if (value.trim().length < 4) {
                return 'Code must be at least 4 characters';
              }
              if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value.trim())) {
                return 'Code must contain only letters and numbers';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'School Address *',
              hintText: 'Enter full address',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter school address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsStep() {
    return Form(
      key: _step2FormKey,
      child: Column(
        children: [
          IntlPhoneField(
            controller: _contactPhoneController,
            decoration: InputDecoration(
              labelText: 'Contact Phone *',
              hintText: 'Enter phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            initialCountryCode: 'GH', // Ghana as default
            onChanged: (phone) {
              // The complete number with country code is in phone.completeNumber
              print('Phone number changed: ${phone.completeNumber}');
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Please enter contact phone';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          TextFormField(
            controller: _contactEmailController,
            decoration: InputDecoration(
              labelText: 'Contact Email',
              hintText: 'info@school.com',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'This contact information will be visible to parents and teachers',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
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

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16.h),
        _buildReviewItem('School Name', _schoolNameController.text),
        _buildReviewItem('School Code', _schoolCodeController.text),
        _buildReviewItem('Address', _addressController.text),
        _buildReviewItem('Contact Phone', _contactPhoneController.text),
        _buildReviewItem(
          'Contact Email',
          _contactEmailController.text.isEmpty
              ? 'Not provided'
              : _contactEmailController.text,
        ),
        SizedBox(height: 16.h),
        _buildReviewItem('Admin', '${widget.firstName} ${widget.lastName}'),
        _buildReviewItem('Admin Phone', widget.phoneNumber),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'What happens next?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                          ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildNextStepItem('Set up classes and grade levels'),
              _buildNextStepItem('Configure fee structure'),
              _buildNextStepItem('Add teachers and students'),
              _buildNextStepItem('Start managing attendance and fees'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 32.w),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            size: 16.sp,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _onStepContinue() {
    print('_onStepContinue called, current step: $_currentStep'); // Debug

    if (_currentStep == 0) {
      // Validate step 1 fields
      final isValid = _step1FormKey.currentState?.validate() ?? false;
      print('Step 0 validation result: $isValid'); // Debug

      if (isValid) {
        setState(() {
          _currentStep = 1;
        });
        print('Moved to step 1'); // Debug
      }
    } else if (_currentStep == 1) {
      // Validate step 2 fields
      final isValid = _step2FormKey.currentState?.validate() ?? false;
      print('Step 1 validation result: $isValid'); // Debug

      if (isValid) {
        setState(() {
          _currentStep = 2;
        });
        print('Moved to step 2'); // Debug
      }
    } else if (_currentStep == 2) {
      print('Calling _handleComplete'); // Debug
      _handleComplete();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final schoolService = GetIt.instance<SchoolService>();

      // Create school with admin in one transaction
      final schoolId = await schoolService.createSchool(
        name: _schoolNameController.text.trim(),
        code: _schoolCodeController.text.trim().toUpperCase(),
        address: _addressController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim().isEmpty
            ? null
            : _contactEmailController.text.trim(),
        adminUserId: widget.userId,
        adminFirstName: widget.firstName,
        adminLastName: widget.lastName,
      );

      print('✅ School created successfully with ID: $schoolId');

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('School created successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Small delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to classes setup (next step in admin onboarding)
      Navigator.pushReplacementNamed(
        context,
        AppRouter.classesSetup,
        arguments: {
          'schoolId': schoolId,
          'userId': widget.userId,
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
