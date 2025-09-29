import 'package:flutter/material.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/student_management/presentation/pages/students_list_page.dart';
import '../../features/student_management/presentation/pages/student_details_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/fee_collection/presentation/pages/fee_collection_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/school_management/presentation/pages/school_settings_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String dashboard = '/dashboard';
  static const String studentsList = '/students';
  static const String studentDetails = '/students/details';
  static const String attendance = '/attendance';
  static const String feeCollection = '/fee-collection';
  static const String reports = '/reports';
  static const String schoolSettings = '/school-settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationPage(
            phoneNumber: args?['phoneNumber'] ?? '',
          ),
          settings: settings,
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardPage(),
          settings: settings,
        );

      case studentsList:
        return MaterialPageRoute(
          builder: (_) => const StudentsListPage(),
          settings: settings,
        );

      case studentDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => StudentDetailsPage(
            studentId: args?['studentId'] ?? '',
          ),
          settings: settings,
        );

      case attendance:
        return MaterialPageRoute(
          builder: (_) => const AttendancePage(),
          settings: settings,
        );

      case feeCollection:
        return MaterialPageRoute(
          builder: (_) => const FeeCollectionPage(),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const ReportsPage(),
          settings: settings,
        );

      case schoolSettings:
        return MaterialPageRoute(
          builder: (_) => const SchoolSettingsPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}
