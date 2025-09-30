import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  /// Check if school has basic setup (classes, teachers, students)
  Future<bool> hasCompletedSchoolSetup(String schoolId) async {
    try {
      // Check if school has at least one class
      final classes = await database.query(
        DatabaseHelper.tableClasses,
        where: 'school_id = ?',
        whereArgs: [schoolId],
        limit: 1,
      );

      if (classes.isEmpty) {
        return false;
      }

      // Check if school has at least one teacher
      final teachers = await database.query(
        DatabaseHelper.tableSchoolTeachers,
        where: 'school_id = ?',
        whereArgs: [schoolId],
        limit: 1,
      );

      if (teachers.isEmpty) {
        return false;
      }

      // Check if school has at least one student
      final students = await database.query(
        DatabaseHelper.tableStudents,
        where: 'school_id = ?',
        whereArgs: [schoolId],
        limit: 1,
      );

      if (students.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error checking school setup completion: $e');
      return false;
    }
  }

  /// Check if classes setup is completed (has at least one class)
  Future<bool> hasCompletedClassesSetup(String schoolId) async {
    try {
      final classes = await database.query(
        DatabaseHelper.tableClasses,
        where: 'school_id = ?',
        whereArgs: [schoolId],
        limit: 1,
      );

      return classes.isNotEmpty;
    } catch (e) {
      print('Error checking classes setup completion: $e');
      return false;
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

      // Check if school has basic setup (classes, teachers, students)
      final hasSchoolSetup = await hasCompletedSchoolSetup(schoolId);

      if (hasSchoolSetup) {
        // User is fully onboarded
        return OnboardingStep.completed;
      }

      // Check if classes are already set up
      final hasClasses = await hasCompletedClassesSetup(schoolId);

      if (hasClasses) {
        // Classes exist, but teachers/students might be missing
        // Check if we need to go to fee structure or bulk upload
        final teachers = await database.query(
          DatabaseHelper.tableSchoolTeachers,
          where: 'school_id = ?',
          whereArgs: [schoolId],
          limit: 1,
        );

        if (teachers.isEmpty) {
          // No teachers, go to bulk upload
          return OnboardingStep.schoolSetup; // This will route to bulk upload
        }

        // Check if fee structure is set up
        final school = await database.query(
          DatabaseHelper.tableSchools,
          where: 'id = ?',
          whereArgs: [schoolId],
          limit: 1,
        );

        if (school.isNotEmpty) {
          final schoolData = school.first;
          final settingsJson = schoolData['settings'] as String?;

          if (settingsJson != null && settingsJson.isNotEmpty) {
            try {
              final settings = jsonDecode(settingsJson);
              final feeStructure = settings['fee_structure'];

              // Check if fee structure is configured
              if (feeStructure != null &&
                  feeStructure['canteen_fee'] != null &&
                  feeStructure['transport_fee'] != null) {
                // Fee structure is configured, check if we need bulk upload
                final students = await database.query(
                  DatabaseHelper.tableStudents,
                  where: 'school_id = ?',
                  whereArgs: [schoolId],
                  limit: 1,
                );

                if (students.isEmpty) {
                  // No students, go to bulk upload
                  return OnboardingStep
                      .schoolSetup; // This will route to bulk upload
                }

                // Everything is set up
                return OnboardingStep.completed;
              }
            } catch (e) {
              print('Error parsing school settings: $e');
            }
          }

          // Fee structure not set up, go to fee structure setup
          return OnboardingStep.schoolSetup; // This will route to fee structure
        }

        // If we reach here, everything is set up
        return OnboardingStep.completed;
      }

      // No classes set up, go to classes setup
      return OnboardingStep.schoolSetup;
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
