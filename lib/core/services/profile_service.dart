import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/data/datasources/local/database_helper.dart';

class ProfileService {
  final Database database;
  final SharedPreferences sharedPreferences;
  final SupabaseClient supabaseClient;

  ProfileService({
    required this.database,
    required this.sharedPreferences,
    required this.supabaseClient,
  });

  /// Save user profile data temporarily (before role selection)
  Future<void> saveProfileData({
    required String userId,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    try {
      // Update Supabase user metadata
      await supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'first_name': firstName,
            'last_name': lastName,
            'display_name': '$firstName $lastName',
            if (photoUrl != null) 'photo_url': photoUrl,
          },
        ),
      );

      // Save to SharedPreferences for temporary storage
      await sharedPreferences.setString('profile_user_id', userId);
      await sharedPreferences.setString('profile_first_name', firstName);
      await sharedPreferences.setString('profile_last_name', lastName);
      if (photoUrl != null) {
        await sharedPreferences.setString('profile_photo_url', photoUrl);
      }

      print('✅ Profile data saved to Supabase and locally');
    } catch (e) {
      print('❌ Error saving profile data: $e');
      throw Exception('Failed to save profile data');
    }
  }

  /// Get saved profile data
  Future<Map<String, String>?> getProfileData() async {
    try {
      final userId = sharedPreferences.getString('profile_user_id');
      final firstName = sharedPreferences.getString('profile_first_name');
      final lastName = sharedPreferences.getString('profile_last_name');
      final photoUrl = sharedPreferences.getString('profile_photo_url');

      if (userId != null && firstName != null && lastName != null) {
        return {
          'userId': userId,
          'firstName': firstName,
          'lastName': lastName,
          if (photoUrl != null) 'photoUrl': photoUrl,
        };
      }

      return null;
    } catch (e) {
      print('Error getting profile data: $e');
      return null;
    }
  }

  /// Clear temporary profile data
  Future<void> clearProfileData() async {
    try {
      await sharedPreferences.remove('profile_user_id');
      await sharedPreferences.remove('profile_first_name');
      await sharedPreferences.remove('profile_last_name');
      await sharedPreferences.remove('profile_photo_url');
    } catch (e) {
      print('Error clearing profile data: $e');
    }
  }
}
