import 'package:flutter/material.dart';

import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/otp_verification_page.dart';
import '../../features/authentication/presentation/pages/profile_setup_page.dart';
import '../../features/authentication/presentation/pages/role_selection_page.dart';
import '../../features/authentication/presentation/pages/school_setup_page.dart';
import '../../features/authentication/presentation/pages/school_join_page.dart';
import '../../features/authentication/presentation/pages/dashboard_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String profileSetup = '/profile-setup';
  static const String roleSelection = '/role-selection';
  static const String schoolSetup = '/school-setup';
  static const String schoolJoin = '/school-join';
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
        print('OTP route called with args: $args'); // Debug log
        return MaterialPageRoute(
          builder: (_) => OTPVerificationPage(
            phoneNumber: args?['phoneNumber'] ?? '',
          ),
          settings: settings,
        );

      case profileSetup:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProfileSetupPage(
            userId: args?['userId'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
          ),
          settings: settings,
        );

      case roleSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RoleSelectionPage(
            userId: args?['userId'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
            firstName: args?['firstName'] ?? '',
            lastName: args?['lastName'] ?? '',
          ),
          settings: settings,
        );

      case schoolSetup:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SchoolSetupPage(
            userId: args?['userId'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
            firstName: args?['firstName'] ?? '',
            lastName: args?['lastName'] ?? '',
          ),
          settings: settings,
        );

      case schoolJoin:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SchoolJoinPage(
            userId: args?['userId'] ?? '',
            phoneNumber: args?['phoneNumber'] ?? '',
            firstName: args?['firstName'] ?? '',
            lastName: args?['lastName'] ?? '',
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
          builder: (_) => const Scaffold(
            body: Center(child: Text('Students List - Coming Soon')),
          ),
          settings: settings,
        );

      case studentDetails:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Student Details - Coming Soon')),
          ),
          settings: settings,
        );

      case attendance:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Attendance - Coming Soon')),
          ),
          settings: settings,
        );

      case feeCollection:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Fee Collection - Coming Soon')),
          ),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Reports - Coming Soon')),
          ),
          settings: settings,
        );

      case schoolSettings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('School Settings - Coming Soon')),
          ),
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
