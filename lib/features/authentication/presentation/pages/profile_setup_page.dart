import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class ProfileSetupPage extends StatefulWidget {
  final String userId;
  final String phoneNumber;

  const ProfileSetupPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        automaticallyImplyLeading: false,
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
                _buildProfilePhoto(),
                SizedBox(height: 24.h),
                _buildFirstNameField(),
                SizedBox(height: 16.h),
                _buildLastNameField(),
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
          Icons.person_outline,
          size: 64.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Tell us about yourself',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'This information will be used to personalize your experience',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50.sp,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 18.r,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  // TODO: Implement photo picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Photo upload coming soon'),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: InputDecoration(
        labelText: 'First Name',
        hintText: 'Enter your first name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your first name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: InputDecoration(
        labelText: 'Last Name',
        hintText: 'Enter your last name',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textCapitalization: TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your last name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleContinue,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: _isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Continue'),
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
      // TODO: Save profile to database
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // For now, navigate to role selection
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRouter.roleSelection,
        arguments: {
          'userId': widget.userId,
          'phoneNumber': widget.phoneNumber,
          'firstName': firstName,
          'lastName': lastName,
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
