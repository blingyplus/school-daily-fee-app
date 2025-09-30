import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/data/datasources/local/database_helper.dart';

@singleton
class OnboardingService {
  final Database database;
  final SharedPreferences sharedPreferences;

  OnboardingService({
    required this.database,
    required this.sharedPreferences,
  });

  /// Check if user has completed their profile
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      // Check SharedPreferences for saved profile
      final savedUserId = sharedPreferences.getString('profile_user_id');
      final firstName = sharedPreferences.getString('profile_first_name');
      final lastName = sharedPreferences.getString('profile_last_name');

      if (savedUserId == userId &&
          firstName != null &&
          firstName.isNotEmpty &&
          lastName != null &&
          lastName.isNotEmpty) {
        return true;
      }

      // Check if user has first_name and last_name in teachers table
      final teachers = await database.query(
        DatabaseHelper.tableTeachers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (teachers.isNotEmpty) {
        final teacher = teachers.first;
        return teacher['first_name'] != null &&
            teacher['last_name'] != null &&
            (teacher['first_name'] as String).isNotEmpty &&
            (teacher['last_name'] as String).isNotEmpty;
      }

      return false;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  /// Check if user has joined/created a school
  Future<String?> getUserSchool(String userId) async {
    try {
      // Check school_teachers table for teacher associations
      final schoolTeachers = await database.query(
        DatabaseHelper.tableSchoolTeachers,
        where:
            'teacher_id IN (SELECT id FROM ${DatabaseHelper.tableTeachers} WHERE user_id = ?)',
        whereArgs: [userId],
        limit: 1,
      );

      if (schoolTeachers.isNotEmpty) {
        return schoolTeachers.first['school_id'] as String;
      }

      // Check admins table for admin associations
      final admins = await database.rawQuery('''
        SELECT a.school_id 
        FROM admins a 
        WHERE a.user_id = ? 
        LIMIT 1
      ''', [userId]);

      if (admins.isNotEmpty) {
        return admins.first['school_id'] as String;
      }

      return null;
    } catch (e) {
      print('Error checking school association: $e');
      return null;
    }
  }

  /// Get user role (admin or teacher)
  Future<String?> getUserRole(String userId) async {
    try {
      // Check if user is a teacher
      final teachers = await database.query(
        DatabaseHelper.tableTeachers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (teachers.isNotEmpty) {
        return 'teacher';
      }

      // Check if user is an admin
      final admins = await database.rawQuery('''
        SELECT * FROM admins WHERE user_id = ? LIMIT 1
      ''', [userId]);

      if (admins.isNotEmpty) {
        return 'admin';
      }

      return null;
    } catch (e) {
      print('Error checking user role: $e');
      return null;
    }
  }

  /// Get profile completion data
  Future<Map<String, dynamic>?> getProfileData(String userId) async {
    try {
      // First check SharedPreferences
      final savedUserId = sharedPreferences.getString('profile_user_id');
      if (savedUserId == userId) {
        final firstName = sharedPreferences.getString('profile_first_name');
        final lastName = sharedPreferences.getString('profile_last_name');

        if (firstName != null && lastName != null) {
          return {
            'first_name': firstName,
            'last_name': lastName,
            'photo_url': sharedPreferences.getString('profile_photo_url'),
          };
        }
      }

      // Check teachers table
      final teachers = await database.query(
        DatabaseHelper.tableTeachers,
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (teachers.isNotEmpty) {
        return teachers.first;
      }

      return null;
    } catch (e) {
      print('Error getting profile data: $e');
      return null;
    }
  }

  /// Determine next onboarding step for a user
  Future<OnboardingStep> getNextStep(String userId) async {
    try {
      // Check if user has profile
      final hasProfile = await hasCompletedProfile(userId);

      if (!hasProfile) {
        return OnboardingStep.profileSetup;
      }

      // Check if user has school
      final schoolId = await getUserSchool(userId);

      if (schoolId == null) {
        return OnboardingStep.roleSelection;
      }

      // User is fully onboarded
      return OnboardingStep.completed;
    } catch (e) {
      print('Error determining next step: $e');
      return OnboardingStep.profileSetup;
    }
  }
}

enum OnboardingStep {
  profileSetup,
  roleSelection,
  schoolSetup,
  schoolJoin,
  completed,
}
