import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sqflite/sqflite.dart';

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
import 'features/authentication/presentation/bloc/auth_state.dart' as app_auth;
import 'features/authentication/presentation/pages/login_page.dart';
import 'core/widgets/splash_screen.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/fee_collection/presentation/bloc/fee_collection_bloc.dart';
import 'features/student_management/presentation/bloc/student_bloc.dart';
import 'shared/data/datasources/local/database_helper.dart';
import 'dart:convert';
import 'core/constants/environment.dart' as env;

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

  /// Download existing user data from Supabase to local database
  Future<void> _downloadUserData(String userId) async {
    if (!env.Environment.useSupabase) {
      print('⚠️ Supabase not enabled, skipping remote data download');
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final database = GetIt.instance<Database>();

      print('📥 Downloading user data for userId: $userId');

      // 1. Check if user has teacher record
      final teacherData = await supabase
          .from('teachers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (teacherData != null) {
        print('✅ Found teacher record');

        // Save teacher to local database
        await database.insert(
          DatabaseHelper.tableTeachers,
          {
            'id': teacherData['id'],
            'user_id': teacherData['user_id'],
            'first_name': teacherData['first_name'],
            'last_name': teacherData['last_name'],
            'employee_id': teacherData['employee_id'],
            'photo_url': teacherData['photo_url'],
            'created_at': DateTime.parse(teacherData['created_at'])
                .millisecondsSinceEpoch,
            'updated_at': DateTime.parse(teacherData['updated_at'])
                .millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // 2. Get school associations for this teacher
        final schoolTeachers = await supabase
            .from('school_teachers')
            .select('*, schools(*)')
            .eq('teacher_id', teacherData['id']);

        for (final st in schoolTeachers) {
          print('✅ Found school association: ${st['schools']['name']}');

          // Save school
          final schoolData = st['schools'];
          await database.insert(
            DatabaseHelper.tableSchools,
            {
              'id': schoolData['id'],
              'name': schoolData['name'],
              'code': schoolData['code'],
              'address': schoolData['address'],
              'contact_phone': schoolData['contact_phone'],
              'contact_email': schoolData['contact_email'],
              'subscription_tier': schoolData['subscription_tier'],
              'subscription_expires_at':
                  schoolData['subscription_expires_at'] != null
                      ? DateTime.parse(schoolData['subscription_expires_at'])
                          .millisecondsSinceEpoch
                      : null,
              'settings': schoolData['settings']?.toString(),
              'is_active': (schoolData['is_active'] as bool) ? 1 : 0,
              'created_at': DateTime.parse(schoolData['created_at'])
                  .millisecondsSinceEpoch,
              'updated_at': DateTime.parse(schoolData['updated_at'])
                  .millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Save school-teacher association
          await database.insert(
            DatabaseHelper.tableSchoolTeachers,
            {
              'id': st['id'],
              'school_id': st['school_id'],
              'teacher_id': st['teacher_id'],
              'role': st['role'],
              'assigned_classes': st['assigned_classes']?.toString(),
              'is_active': (st['is_active'] as bool) ? 1 : 0,
              'assigned_at':
                  DateTime.parse(st['assigned_at']).millisecondsSinceEpoch,
              'created_at':
                  DateTime.parse(st['created_at']).millisecondsSinceEpoch,
              'updated_at':
                  DateTime.parse(st['updated_at']).millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          final schoolId = st['school_id'];

          // 3. Download classes for this school
          final classes =
              await supabase.from('classes').select().eq('school_id', schoolId);

          print('✅ Found ${classes.length} classes');
          for (final classData in classes) {
            await database.insert(
              DatabaseHelper.tableClasses,
              {
                'id': classData['id'],
                'school_id': classData['school_id'],
                'name': classData['name'],
                'grade_level': classData['grade_level'],
                'section': classData['section'],
                'academic_year': classData['academic_year'],
                'is_active': (classData['is_active'] as bool) ? 1 : 0,
                'created_at': DateTime.parse(classData['created_at'])
                    .millisecondsSinceEpoch,
                'updated_at': DateTime.parse(classData['updated_at'])
                    .millisecondsSinceEpoch,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          // 4. Download students for this school
          final students = await supabase
              .from('students')
              .select()
              .eq('school_id', schoolId)
              .limit(100); // Limit to first 100 for initial sync

          print('✅ Found ${students.length} students');
          for (final studentData in students) {
            await database.insert(
              DatabaseHelper.tableStudents,
              {
                'id': studentData['id'],
                'school_id': studentData['school_id'],
                'class_id': studentData['class_id'],
                'student_id': studentData['student_id'],
                'first_name': studentData['first_name'],
                'last_name': studentData['last_name'],
                'date_of_birth': studentData['date_of_birth'] != null
                    ? DateTime.parse(studentData['date_of_birth'])
                        .millisecondsSinceEpoch
                    : null,
                'photo_url': studentData['photo_url'],
                'parent_phone': studentData['parent_phone'],
                'parent_email': studentData['parent_email'],
                'address': studentData['address'],
                'is_active': (studentData['is_active'] as bool) ? 1 : 0,
                'enrolled_at': DateTime.parse(studentData['enrolled_at'])
                    .millisecondsSinceEpoch,
                'created_at': DateTime.parse(studentData['created_at'])
                    .millisecondsSinceEpoch,
                'updated_at': DateTime.parse(studentData['updated_at'])
                    .millisecondsSinceEpoch,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }

      // 5. Check if user is an admin
      final adminData = await supabase
          .from('admins')
          .select('*, schools(*)')
          .eq('user_id', userId)
          .maybeSingle();

      if (adminData != null) {
        print('✅ Found admin record');

        // Save admin
        await database.insert(
          DatabaseHelper.tableAdmins,
          {
            'id': adminData['id'],
            'user_id': adminData['user_id'],
            'school_id': adminData['school_id'],
            'first_name': adminData['first_name'],
            'last_name': adminData['last_name'],
            'photo_url': adminData['photo_url'],
            'created_at':
                DateTime.parse(adminData['created_at']).millisecondsSinceEpoch,
            'updated_at':
                DateTime.parse(adminData['updated_at']).millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // School should already be saved if user is also a teacher,
        // but save it again to be sure
        final schoolData = adminData['schools'];
        if (schoolData != null) {
          await database.insert(
            DatabaseHelper.tableSchools,
            {
              'id': schoolData['id'],
              'name': schoolData['name'],
              'code': schoolData['code'],
              'address': schoolData['address'],
              'contact_phone': schoolData['contact_phone'],
              'contact_email': schoolData['contact_email'],
              'subscription_tier': schoolData['subscription_tier'],
              'subscription_expires_at':
                  schoolData['subscription_expires_at'] != null
                      ? DateTime.parse(schoolData['subscription_expires_at'])
                          .millisecondsSinceEpoch
                      : null,
              'settings': schoolData['settings']?.toString(),
              'is_active': (schoolData['is_active'] as bool) ? 1 : 0,
              'created_at': DateTime.parse(schoolData['created_at'])
                  .millisecondsSinceEpoch,
              'updated_at': DateTime.parse(schoolData['updated_at'])
                  .millisecondsSinceEpoch,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      print('✅ User data download complete');
    } catch (e) {
      print('❌ Error downloading user data: $e');
      // Don't throw - let the app continue with local data
    }
  }

  Future<void> _handleOnboardingNavigation(
      BuildContext context, String userId, String phoneNumber) async {
    try {
      // First, download user-specific data from Supabase for existing users
      print('🔄 Checking for existing user data in Supabase...');
      await _downloadUserData(userId);

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
                home: BlocListener<AuthBloc, app_auth.AuthState>(
                  listener: (context, state) {
                    if (state is app_auth.AuthOTPSent) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.otpVerification,
                        arguments: {'phoneNumber': state.phoneNumber},
                      );
                    } else if (state is app_auth.AuthAuthenticated) {
                      // Check onboarding status and route accordingly
                      _handleOnboardingNavigation(
                          context, state.user.id, state.user.phoneNumber);
                    } else if (state is app_auth.AuthError) {
                      // Show error message to user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: 'OK',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<AuthBloc, app_auth.AuthState>(
                    builder: (context, state) {
                      if (state is app_auth.AuthAuthenticated) {
                        // Navigate to dashboard immediately - don't wait for sync
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _handleOnboardingNavigation(
                              context, state.user.id, state.user.phoneNumber);
                        });
                        // Show splash screen while navigating
                        return const SplashScreen();
                      } else {
                        // AuthInitial, AuthUnauthenticated, AuthLoading, AuthOTPSent, or AuthError
                        // Keep LoginPage mounted so phone number persists
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
