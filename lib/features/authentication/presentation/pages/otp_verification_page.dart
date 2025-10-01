import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/sync/sync_engine.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  bool _isSyncing = false;
  int _resendTimer = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60; // 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                setState(() {
                  _isLoading = false;
                });
                // Check onboarding status and route accordingly
                _handleOnboardingNavigation(
                    state.user.id, state.user.phoneNumber);
              } else if (state is AuthError) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (state is AuthOTPResent) {
                setState(() {
                  _isResending = false;
                });
                _startResendTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('OTP sent successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is AuthLoading) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.largePadding.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        (AppConstants.largePadding.w * 2),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildHeader(),
                              SizedBox(height: 48.h),
                              _buildOTPForm(),
                            ],
                          ),
                        ),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Show syncing overlay when syncing
          if (_isSyncing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Syncing your data...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Icon(
            Icons.sms,
            size: 40.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Enter Verification Code',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 8.h),
        Text(
          'We sent a 6-digit code to',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        SizedBox(height: 4.h),
        Text(
          widget.phoneNumber,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildOTPForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOTPInputFields(),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleOTPVerification,
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
                : const Text('Verify OTP'),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45.w,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 8.w,
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
            onTap: () {
              _otpControllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _otpControllers[index].text.length),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        if (_resendTimer > 0)
          Text(
            'Resend code in ${_resendTimer}s',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          )
        else
          TextButton(
            onPressed: _isResending ? null : _handleResendOTP,
            child: _isResending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Resend Code'),
          ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Change Phone Number'),
        ),
      ],
    );
  }

  void _handleOTPVerification() {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    context.read<AuthBloc>().add(
          AuthOTPVerificationRequested(
            phoneNumber: widget.phoneNumber,
            otp: otp,
          ),
        );
  }

  void _handleResendOTP() {
    setState(() {
      _isResending = true;
    });

    context.read<AuthBloc>().add(
          AuthOTPResendRequested(phoneNumber: widget.phoneNumber),
        );
  }

  Future<void> _handleOnboardingNavigation(
      String userId, String phoneNumber) async {
    try {
      // Show syncing state
      if (mounted) {
        setState(() {
          _isSyncing = true;
        });
      }

      // First, trigger sync to ensure local database is populated with remote data
      print('🔄 Triggering sync before checking onboarding status...');
      final syncEngine = GetIt.instance<SyncEngine>();
      final syncResult = await syncEngine.sync(SyncDirection.download);

      if (syncResult.status == SyncStatus.success) {
        print(
            '✅ Sync completed successfully, proceeding with onboarding check');
      } else {
        print(
            '⚠️ Sync failed or had issues, proceeding anyway: ${syncResult.message}');
      }

      // Hide syncing state
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }

      final onboardingService = GetIt.instance<OnboardingService>();
      final nextStep = await onboardingService.getNextStep(userId);

      if (!mounted) return;

      switch (nextStep) {
        case OnboardingStep.profileSetup:
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.profileSetup,
            (route) => false,
            arguments: {
              'userId': userId,
              'phoneNumber': phoneNumber,
            },
          );
          break;

        case OnboardingStep.roleSelection:
          // Get profile data to pass names
          final profileData = await onboardingService.getProfileData(userId);
          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.roleSelection,
            (route) => false,
            arguments: {
              'userId': userId,
              'phoneNumber': phoneNumber,
              'firstName': profileData?['first_name'] ?? '',
              'lastName': profileData?['last_name'] ?? '',
            },
          );
          break;

        case OnboardingStep.schoolSetup:
          // User needs to complete school setup (classes, teachers, students)
          final schoolId = await onboardingService.getUserSchool(userId);
          final role = await onboardingService.getUserRole(userId);

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.classesSetup,
            (route) => false,
            arguments: {
              'userId': userId,
              'schoolId': schoolId,
              'role': role,
            },
          );
          break;

        case OnboardingStep.completed:
          // User has completed onboarding, go to dashboard
          final schoolId = await onboardingService.getUserSchool(userId);
          final role = await onboardingService.getUserRole(userId);

          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.dashboard,
            (route) => false,
            arguments: {
              'userId': userId,
              'schoolId': schoolId,
              'role': role,
            },
          );
          break;

        default:
          // Default to profile setup
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.profileSetup,
            (route) => false,
            arguments: {
              'userId': userId,
              'phoneNumber': phoneNumber,
            },
          );
      }
    } catch (e) {
      print('Error in onboarding navigation: $e');
      // Default to profile setup on error
      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.profileSetup,
        (route) => false,
        arguments: {
          'userId': userId,
          'phoneNumber': phoneNumber,
        },
      );
    }
  }
}
