import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/presentation/widgets/custom_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _countryCode = '+233'; // Ghana country code

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          // Only listen to states that matter for the login flow
          // Ignore initial auth checks that happen on app start
          return current is AuthOTPSent ||
              current is AuthError ||
              (current is AuthLoading &&
                  previous is! AuthInitial &&
                  previous is! AuthUnauthenticated);
        },
        listener: (context, state) {
          print('Login page received state: $state'); // Debug log
          if (state is AuthError) {
            setState(() {
              _isLoading = false;
            });
            // Error snackbar is handled by main.dart BlocListener
            // Phone number persists automatically since page is not recreated
          } else if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else if (state is AuthOTPSent) {
            setState(() {
              _isLoading = false;
            });
            // Navigation is handled by main.dart BlocListener
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.largePadding.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),
                SizedBox(height: 48.h),
                _buildLoginForm(),
                SizedBox(height: 40.h),
                _buildFooter(),
                SizedBox(height: 20.h),
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
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(60.r),
          ),
          child: Icon(
            Icons.school,
            size: 60.sp,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Skuupay',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Manage canteen and transport fees easily',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your phone number',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'We\'ll send you a verification code',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),
          IntlPhoneField(
            controller: _phoneController,
            initialCountryCode: 'GH', // Ghana
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
            ),
            onChanged: (phone) {
              _countryCode = phone.countryCode;
            },
            validator: (phone) {
              if (phone == null || phone.number.isEmpty) {
                return 'Please enter your phone number';
              }
              if (phone.number.length < 9) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 32.h),
          CustomButton(
            text: 'Send OTP',
            onPressed: _isLoading ? null : _handleLogin,
            isLoading: _isLoading,
            isFullWidth: true,
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(
          color: Theme.of(context).colorScheme.outline,
        ),
        SizedBox(height: 16.h),
        Text(
          'By continuing, you agree to our Terms of Service and Privacy Policy',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleLogin() {
    print('_handleLogin called'); // Debug log
    if (_formKey.currentState?.validate() ?? false) {
      final phoneNumber = '$_countryCode${_phoneController.text.trim()}';
      print(
          'Dispatching AuthLoginRequested with phone: $phoneNumber'); // Debug log
      context.read<AuthBloc>().add(
            AuthLoginRequested(phoneNumber: phoneNumber),
          );
    } else {
      print('Form validation failed'); // Debug log
    }
  }
}
