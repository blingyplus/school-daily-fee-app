import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/network/supabase_client.dart';
import 'core/services/onboarding_service.dart';
import 'core/sync/sync_engine.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/fee_collection/presentation/bloc/fee_collection_bloc.dart';
import 'features/student_management/presentation/bloc/student_bloc.dart';
import 'shared/data/datasources/local/database_helper.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase first
  await SupabaseClientConfig.initialize();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize sync engine
  final syncEngine = GetIt.instance<SyncEngine>();
  await syncEngine.initialize();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize(GetIt.instance<SharedPreferences>());

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  Future<void> _handleOnboardingNavigation(
      BuildContext context, String userId, String phoneNumber) async {
    try {
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

      final onboardingService = GetIt.instance<OnboardingService>();
      final nextStep = await onboardingService.getNextStep(userId);

      if (!context.mounted) return;

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
          if (!context.mounted) return;

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

          if (!context.mounted) return;

          // Determine which setup page to show based on what's missing
          final hasClasses =
              await onboardingService.hasCompletedClassesSetup(schoolId!);

          if (!hasClasses) {
            // No classes, go to classes setup
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
          } else {
            // Classes exist, check what else is missing
            final teachers = await onboardingService.database.query(
              DatabaseHelper.tableSchoolTeachers,
              where: 'school_id = ?',
              whereArgs: [schoolId],
              limit: 1,
            );

            if (teachers.isEmpty) {
              // No teachers, go to bulk upload
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.bulkUpload,
                (route) => false,
                arguments: {
                  'userId': userId,
                  'schoolId': schoolId,
                  'role': role,
                },
              );
            } else {
              // Check if fee structure is set up
              final school = await onboardingService.database.query(
                DatabaseHelper.tableSchools,
                where: 'id = ?',
                whereArgs: [schoolId],
                limit: 1,
              );

              if (school.isNotEmpty) {
                final schoolData = school.first;
                final settingsJson = schoolData['settings'] as String?;

                bool feeStructureConfigured = false;
                if (settingsJson != null && settingsJson.isNotEmpty) {
                  try {
                    final settings = jsonDecode(settingsJson);
                    final feeStructure = settings['fee_structure'];
                    feeStructureConfigured = feeStructure != null &&
                        feeStructure['canteen_fee'] != null &&
                        feeStructure['transport_fee'] != null;
                  } catch (e) {
                    print('Error parsing school settings: $e');
                  }
                }

                if (!feeStructureConfigured) {
                  // Fee structure not set up, go to fee structure setup
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.feeStructureSetup,
                    (route) => false,
                    arguments: {
                      'userId': userId,
                      'schoolId': schoolId,
                      'role': role,
                    },
                  );
                } else {
                  // Check if students exist
                  final students = await onboardingService.database.query(
                    DatabaseHelper.tableStudents,
                    where: 'school_id = ?',
                    whereArgs: [schoolId],
                    limit: 1,
                  );

                  if (students.isEmpty) {
                    // No students, go to bulk upload
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.bulkUpload,
                      (route) => false,
                      arguments: {
                        'userId': userId,
                        'schoolId': schoolId,
                        'role': role,
                      },
                    );
                  } else {
                    // Everything is set up, go to dashboard
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
                  }
                }
              } else {
                // School not found, go to classes setup as fallback
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
              }
            }
          }
          break;

        case OnboardingStep.completed:
          // User has completed onboarding, go to dashboard
          final schoolId = await onboardingService.getUserSchool(userId);
          final role = await onboardingService.getUserRole(userId);

          if (!context.mounted) return;

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
          // Fallback to profile setup
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
      // Fallback to profile setup on error
      if (context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              GetIt.instance<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<StudentBloc>(
          create: (context) => GetIt.instance<StudentBloc>(),
        ),
        BlocProvider<AttendanceBloc>(
          create: (context) => GetIt.instance<AttendanceBloc>(),
        ),
        BlocProvider<FeeCollectionBloc>(
          create: (context) => GetIt.instance<FeeCollectionBloc>(),
        ),
      ],
      child: AnimatedBuilder(
        animation: themeProvider,
        builder: (context, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'Skuupay',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                navigatorKey: NavigationService.navigatorKey,
                onGenerateRoute: AppRouter.generateRoute,
                home: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOTPSent) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.otpVerification,
                        arguments: {'phoneNumber': state.phoneNumber},
                      );
                    } else if (state is AuthAuthenticated) {
                      // Check onboarding status and route accordingly
                      _handleOnboardingNavigation(
                          context, state.user.id, state.user.phoneNumber);
                    }
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is AuthAuthenticated) {
                        // Show loading while syncing and checking onboarding status
                        return const Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Syncing your data...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const LoginPage();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
