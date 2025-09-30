import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/navigation/app_router.dart';

class RoleSelectionPage extends StatefulWidget {
  final String userId;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  const RoleSelectionPage({
    super.key,
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              Expanded(
                child: ListView(
                  children: [
                    _buildRoleCard(
                      title: 'I\'m an Admin',
                      subtitle: 'Set up and manage your school',
                      icon: Icons.admin_panel_settings,
                      role: 'admin',
                      features: [
                        'Create and manage school',
                        'Add teachers and students',
                        'View comprehensive reports',
                        'Manage fees and scholarships',
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildRoleCard(
                      title: 'I\'m a Teacher',
                      subtitle: 'Join a school and manage daily operations',
                      icon: Icons.school,
                      role: 'teacher',
                      features: [
                        'Join existing schools',
                        'Mark attendance',
                        'Collect fees',
                        'View daily reports',
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
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
        Text(
          'Welcome, ${widget.firstName}!',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Choose your role to continue',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required List<String> features,
  }) {
    final isSelected = _selectedRole == role;

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        borderRadius: BorderRadius.circular(16.r),
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
                      icon,
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
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          subtitle,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28.sp,
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              ...features.map((feature) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            feature,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _selectedRole == null ? null : _handleContinue,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: const Text('Continue'),
    );
  }

  void _handleContinue() {
    if (_selectedRole == null) return;

    if (_selectedRole == 'admin') {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.schoolSetup,
        arguments: {
          'userId': widget.userId,
          'phoneNumber': widget.phoneNumber,
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'role': _selectedRole,
        },
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.schoolJoin,
        arguments: {
          'userId': widget.userId,
          'phoneNumber': widget.phoneNumber,
          'firstName': widget.firstName,
          'lastName': widget.lastName,
          'role': _selectedRole,
        },
      );
    }
  }
}
