import 'package:flutter/material.dart';

import 'app_router.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? get currentContext => navigatorKey.currentContext;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndReplace(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateAndClearStack(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack([dynamic result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState!.popUntil(ModalRoute.withName(routeName));
  }

  static void popUntilFirst() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  // Convenience methods for common navigation patterns
  static Future<dynamic> goToLogin() {
    return navigateAndClearStack(AppRouter.login);
  }

  static Future<dynamic> goToDashboard() {
    return navigateAndClearStack(AppRouter.dashboard);
  }

  static Future<dynamic> goToStudentsList() {
    return navigateTo(AppRouter.studentsList);
  }

  static Future<dynamic> goToStudentDetails(String studentId) {
    return navigateTo(
      AppRouter.studentDetails,
      arguments: {'studentId': studentId},
    );
  }

  static Future<dynamic> goToAttendance() {
    return navigateTo(AppRouter.attendance);
  }

  static Future<dynamic> goToFeeCollection() {
    return navigateTo(AppRouter.feeCollection);
  }

  static Future<dynamic> goToReports() {
    return navigateTo(AppRouter.reports);
  }

  static Future<dynamic> goToSchoolSettings() {
    return navigateTo(AppRouter.schoolSettings);
  }
}
