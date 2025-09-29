import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/data/datasources/local/database_helper.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel user);
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearUserData();
  Future<void> updateLastLogin(DateTime lastLogin);
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final Database database;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.database,
  });

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final results = await database.query(
        DatabaseHelper.tableUsers,
        where: 'is_active = ?',
        whereArgs: [1],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return UserModel.fromJson(results.first);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      // First, deactivate all existing users
      await database.update(
        DatabaseHelper.tableUsers,
        {'is_active': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'is_active = ?',
        whereArgs: [1],
      );

      // Then insert or update the current user
      await database.insert(
        DatabaseHelper.tableUsers,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user data');
    }
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await sharedPreferences.setString('access_token', accessToken);
      await sharedPreferences.setString('refresh_token', refreshToken);
    } catch (e) {
      print('Error saving tokens: $e');
      throw Exception('Failed to save authentication tokens');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return sharedPreferences.getString('access_token');
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return sharedPreferences.getString('refresh_token');
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> clearUserData() async {
    try {
      // Clear tokens from SharedPreferences
      await sharedPreferences.remove('access_token');
      await sharedPreferences.remove('refresh_token');

      // Deactivate current user in database
      await database.update(
        DatabaseHelper.tableUsers,
        {'is_active': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'is_active = ?',
        whereArgs: [1],
      );
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }

  @override
  Future<void> updateLastLogin(DateTime lastLogin) async {
    try {
      await database.update(
        DatabaseHelper.tableUsers,
        {
          'last_login': lastLogin.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'is_active = ?',
        whereArgs: [1],
      );
    } catch (e) {
      print('Error updating last login: $e');
      throw Exception('Failed to update last login');
    }
  }
}
