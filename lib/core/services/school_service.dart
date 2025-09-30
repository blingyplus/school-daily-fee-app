import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../constants/environment.dart' as env;
import '../sync/sync_engine.dart';
import '../../shared/data/datasources/local/database_helper.dart';
import '../../shared/data/models/school_model.dart';
import '../../shared/data/models/teacher_model.dart';
import '../../shared/data/models/admin_model.dart';

@singleton
class SchoolService {
  final Database database;
  final SupabaseClient supabaseClient;
  final SyncEngine syncEngine;
  final Uuid uuid = const Uuid();

  SchoolService({
    required this.database,
    required this.supabaseClient,
    required this.syncEngine,
  });

  /// Create a new school (Admin flow)
  Future<String> createSchool({
    required String name,
    required String code,
    required String address,
    required String contactPhone,
    String? contactEmail,
    required String adminUserId,
    required String adminFirstName,
    required String adminLastName,
  }) async {
    final now = DateTime.now();
    final schoolId = uuid.v4();
    final teacherId = uuid.v4();

    try {
      // 1. Create school record
      final schoolModel = SchoolModel(
        id: schoolId,
        name: name,
        code: code.toUpperCase(),
        address: address,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        subscriptionTier: 'free',
        subscriptionExpiresAt: null,
        settings: null,
        isActive: true,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      // Save to local DB first (offline-first)
      await database.insert(
        DatabaseHelper.tableSchools,
        schoolModel.toSqliteJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ School saved to local DB');

      // 2. Create teacher record for the admin
      final teacherModel = TeacherModel(
        id: teacherId,
        userId: adminUserId,
        firstName: adminFirstName,
        lastName: adminLastName,
        employeeId: null,
        photoUrl: null,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      await database.insert(
        DatabaseHelper.tableTeachers,
        teacherModel.toSqliteJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Teacher record saved to local DB');

      // 3. Create admin record
      final adminModel = AdminModel(
        id: uuid.v4(),
        userId: adminUserId,
        schoolId: schoolId,
        firstName: adminFirstName,
        lastName: adminLastName,
        photoUrl: null,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );

      await database.insert(
        DatabaseHelper.tableAdmins,
        adminModel.toSqliteJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ Admin record saved to local DB');

      // 4. Create school-teacher association with admin role
      final schoolTeacherData = {
        'id': uuid.v4(),
        'school_id': schoolId,
        'teacher_id': teacherId,
        'role': 'admin',
        'assigned_classes': '[]',
        'is_active': 1,
        'assigned_at': now.millisecondsSinceEpoch,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      await database.insert(
        DatabaseHelper.tableSchoolTeachers,
        schoolTeacherData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ School-Teacher association saved to local DB');

      // 5. Log sync operations
      await syncEngine.logSyncOperation(
        schoolId: schoolId,
        entityType: 'schools',
        entityId: schoolId,
        operation: 'insert',
      );

      await syncEngine.logSyncOperation(
        schoolId: schoolId,
        entityType: 'teachers',
        entityId: teacherId,
        operation: 'insert',
      );

      await syncEngine.logSyncOperation(
        schoolId: schoolId,
        entityType: 'school_teachers',
        entityId: schoolTeacherData['id'] as String,
        operation: 'insert',
      );

      await syncEngine.logSyncOperation(
        schoolId: schoolId,
        entityType: 'admins',
        entityId: adminModel.id,
        operation: 'insert',
      );

      // 6. If online, sync to Supabase immediately
      if (env.Environment.useSupabase) {
        try {
          await _syncToSupabase(
              schoolModel, teacherModel, adminModel, schoolTeacherData);
        } catch (e) {
          print('⚠️ Failed to sync to Supabase, will retry later: $e');
          // Don't throw - data is safely stored locally
        }
      }

      return schoolId;
    } catch (e) {
      print('❌ Error creating school: $e');
      throw Exception('Failed to create school: $e');
    }
  }

  /// Join an existing school (Teacher flow)
  Future<void> joinSchool({
    required String schoolId,
    required String teacherUserId,
    required String teacherFirstName,
    required String teacherLastName,
    String? employeeId,
  }) async {
    final now = DateTime.now();
    final teacherId = uuid.v4();

    try {
      // 1. Check if teacher record exists for this user
      final existingTeachers = await database.query(
        DatabaseHelper.tableTeachers,
        where: 'user_id = ?',
        whereArgs: [teacherUserId],
        limit: 1,
      );

      String finalTeacherId;

      if (existingTeachers.isEmpty) {
        // Create new teacher record
        finalTeacherId = teacherId;
        final teacherModel = TeacherModel(
          id: finalTeacherId,
          userId: teacherUserId,
          firstName: teacherFirstName,
          lastName: teacherLastName,
          employeeId: employeeId,
          photoUrl: null,
          createdAt: now.millisecondsSinceEpoch,
          updatedAt: now.millisecondsSinceEpoch,
        );

        await database.insert(
          DatabaseHelper.tableTeachers,
          teacherModel.toSqliteJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        print('✅ Teacher record created');

        // Log sync
        await syncEngine.logSyncOperation(
          schoolId: schoolId,
          entityType: 'teachers',
          entityId: finalTeacherId,
          operation: 'insert',
        );
      } else {
        finalTeacherId = existingTeachers.first['id'] as String;
        print('✅ Using existing teacher record');
      }

      // 2. Create school-teacher association
      final schoolTeacherData = {
        'id': uuid.v4(),
        'school_id': schoolId,
        'teacher_id': finalTeacherId,
        'role': 'staff',
        'assigned_classes': '[]',
        'is_active': 1,
        'assigned_at': now.millisecondsSinceEpoch,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      };

      await database.insert(
        DatabaseHelper.tableSchoolTeachers,
        schoolTeacherData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('✅ School-Teacher association created');

      // Log sync
      await syncEngine.logSyncOperation(
        schoolId: schoolId,
        entityType: 'school_teachers',
        entityId: schoolTeacherData['id'] as String,
        operation: 'insert',
      );

      // 3. Sync to Supabase if online
      if (env.Environment.useSupabase) {
        try {
          // First, ensure teacher exists in Supabase
          if (existingTeachers.isEmpty) {
            // Get the teacher data and sync to Supabase
            final teacherData = await database.query(
              DatabaseHelper.tableTeachers,
              where: 'id = ?',
              whereArgs: [finalTeacherId],
              limit: 1,
            );

            if (teacherData.isNotEmpty) {
              // Convert timestamps to ISO format for Supabase
              final teacherSupabase =
                  Map<String, dynamic>.from(teacherData.first);
              teacherSupabase['created_at'] =
                  DateTime.fromMillisecondsSinceEpoch(
                          teacherData.first['created_at'] as int)
                      .toIso8601String();
              teacherSupabase['updated_at'] =
                  DateTime.fromMillisecondsSinceEpoch(
                          teacherData.first['updated_at'] as int)
                      .toIso8601String();

              await supabaseClient.from('teachers').insert(teacherSupabase);
              print('✅ Teacher synced to Supabase');
            }
          }

          // Then sync school-teacher association
          final schoolTeacherSupabase =
              Map<String, dynamic>.from(schoolTeacherData);
          schoolTeacherSupabase['assigned_at'] =
              DateTime.fromMillisecondsSinceEpoch(
                      schoolTeacherData['assigned_at'] as int)
                  .toIso8601String();
          schoolTeacherSupabase['created_at'] =
              DateTime.fromMillisecondsSinceEpoch(
                      schoolTeacherData['created_at'] as int)
                  .toIso8601String();
          schoolTeacherSupabase['updated_at'] =
              DateTime.fromMillisecondsSinceEpoch(
                      schoolTeacherData['updated_at'] as int)
                  .toIso8601String();

          await supabaseClient
              .from('school_teachers')
              .insert(schoolTeacherSupabase);
          print('✅ School-Teacher association synced to Supabase');
        } catch (e) {
          print('⚠️ Failed to sync to Supabase, will retry later: $e');
        }
      }
    } catch (e) {
      print('❌ Error joining school: $e');
      throw Exception('Failed to join school: $e');
    }
  }

  /// Search for school by code
  Future<Map<String, dynamic>?> searchSchoolByCode(String code) async {
    try {
      // First check local DB
      final localResults = await database.query(
        DatabaseHelper.tableSchools,
        where: 'code = ? AND is_active = ?',
        whereArgs: [code.toUpperCase(), 1],
        limit: 1,
      );

      if (localResults.isNotEmpty) {
        return localResults.first;
      }

      // If not found locally and online, check Supabase
      if (env.Environment.useSupabase) {
        final response = await supabaseClient
            .from('schools')
            .select()
            .eq('code', code.toUpperCase())
            .eq('is_active', true)
            .limit(1);

        if (response.isNotEmpty) {
          final schoolData = response.first;

          // Save to local DB for offline access
          await database.insert(
            DatabaseHelper.tableSchools,
            SchoolModel.fromJson(schoolData).toSqliteJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          return schoolData;
        }
      }

      return null;
    } catch (e) {
      print('Error searching for school: $e');
      return null;
    }
  }

  /// Sync school data to Supabase
  Future<void> _syncToSupabase(
    SchoolModel school,
    TeacherModel teacher,
    AdminModel admin,
    Map<String, dynamic> schoolTeacher,
  ) async {
    try {
      // Insert school with proper timestamp format
      await supabaseClient.from('schools').insert(school.toSupabaseJson());
      print('✅ School synced to Supabase');

      // Insert teacher with proper timestamp format
      await supabaseClient.from('teachers').insert(teacher.toSupabaseJson());
      print('✅ Teacher synced to Supabase');

      // Insert admin with proper timestamp format
      await supabaseClient.from('admins').insert(admin.toSupabaseJson());
      print('✅ Admin synced to Supabase');

      // Convert school-teacher timestamps to ISO format
      final schoolTeacherSupabase = Map<String, dynamic>.from(schoolTeacher);
      schoolTeacherSupabase['assigned_at'] =
          DateTime.fromMillisecondsSinceEpoch(
                  schoolTeacher['assigned_at'] as int)
              .toIso8601String();
      schoolTeacherSupabase['created_at'] = DateTime.fromMillisecondsSinceEpoch(
              schoolTeacher['created_at'] as int)
          .toIso8601String();
      schoolTeacherSupabase['updated_at'] = DateTime.fromMillisecondsSinceEpoch(
              schoolTeacher['updated_at'] as int)
          .toIso8601String();

      // Insert school-teacher association
      await supabaseClient
          .from('school_teachers')
          .insert(schoolTeacherSupabase);
      print('✅ School-Teacher association synced to Supabase');
    } catch (e) {
      print('Error syncing to Supabase: $e');
      rethrow;
    }
  }
}
