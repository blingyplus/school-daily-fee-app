import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class SchoolJoinPage extends StatefulWidget {
  final String userId;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  const SchoolJoinPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<SchoolJoinPage> createState() => _SchoolJoinPageState();
}

class _SchoolJoinPageState extends State<SchoolJoinPage> {
  final _formKey = GlobalKey<FormState>();
  final _schoolCodeController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool _isLoading = false;
  bool _isSearching = false;
  Map<String, dynamic>? _foundSchool;

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a School'),
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
                _buildSchoolCodeField(),
                SizedBox(height: 16.h),
                _buildSearchButton(),
                if (_foundSchool != null) ...[
                  SizedBox(height: 24.h),
                  _buildSchoolCard(),
                  SizedBox(height: 16.h),
                  _buildEmployeeIdField(),
                  SizedBox(height: 24.h),
                  _buildJoinButton(),
                ],
                SizedBox(height: 24.h),
                _buildHelpSection(),
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
          Icons.school_outlined,
          size: 64.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 16.h),
        Text(
          'Welcome, ${widget.firstName}!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Enter your school code to join',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSchoolCodeField() {
    return TextFormField(
      controller: _schoolCodeController,
      decoration: InputDecoration(
        labelText: 'School Code',
        hintText: 'e.g., SMIS2024',
        helperText: 'Ask your school admin for the code',
        prefixIcon: const Icon(Icons.qr_code),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textCapitalization: TextCapitalization.characters,
      enabled: !_isSearching,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter school code';
        }
        if (value.trim().length < 4) {
          return 'Code must be at least 4 characters';
        }
        return null;
      },
      onChanged: (_) {
        if (_foundSchool != null) {
          setState(() {
            _foundSchool = null;
          });
        }
      },
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: _isSearching || _foundSchool != null ? null : _handleSearch,
      icon: _isSearching
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.search),
      label: Text(_isSearching ? 'Searching...' : 'Search School'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildSchoolCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 32.sp,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _foundSchool!['name'],
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Code: ${_foundSchool!['code']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28.sp,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Divider(height: 1.h),
            SizedBox(height: 16.h),
            _buildSchoolInfoRow(
              Icons.location_on,
              _foundSchool!['address'],
            ),
            SizedBox(height: 8.h),
            _buildSchoolInfoRow(
              Icons.phone,
              _foundSchool!['contact_phone'],
            ),
            if (_foundSchool!['contact_email'] != null &&
                _foundSchool!['contact_email'].isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildSchoolInfoRow(
                Icons.email,
                _foundSchool!['contact_email'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeIdField() {
    return TextFormField(
      controller: _employeeIdController,
      decoration: InputDecoration(
        labelText: 'Employee ID (Optional)',
        hintText: 'Your staff ID number',
        prefixIcon: const Icon(Icons.badge),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      textCapitalization: TextCapitalization.characters,
    );
  }

  Widget _buildJoinButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleJoin,
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
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text('Join School'),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 12.w),
              Text(
                'Need help?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '• Ask your school administrator for the school code\n'
            '• Make sure you enter the code exactly as provided\n'
            '• You can join multiple schools if you teach at different locations',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSearch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // TODO: Search for school by code in database
      final schoolCode = _schoolCodeController.text.trim().toUpperCase();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock school data
      final mockSchool = {
        'id': 'school_123',
        'name': 'St. Mary\'s International School',
        'code': schoolCode,
        'address': '123 Education Street, Accra, Ghana',
        'contact_phone': '+233 XX XXX XXXX',
        'contact_email': 'info@stmarys.edu.gh',
      };

      if (!mounted) return;

      setState(() {
        _foundSchool = mockSchool;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('School not found. Please check the code and try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleJoin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Create teacher record and school_teachers association
      final teacherData = {
        'user_id': widget.userId,
        'first_name': widget.firstName,
        'last_name': widget.lastName,
        'employee_id': _employeeIdController.text.trim(),
        'phone_number': widget.phoneNumber,
      };

      final schoolTeacherData = {
        'school_id': _foundSchool!['id'],
        'role': 'staff',
        'is_active': true,
      };

      print('Teacher Data: $teacherData');
      print('School-Teacher Association: $schoolTeacherData');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // Navigate to dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.dashboard,
        (route) => false,
        arguments: {
          'role': 'teacher',
          'schoolId': _foundSchool!['id'],
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
