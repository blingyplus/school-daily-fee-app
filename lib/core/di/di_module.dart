import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/environment.dart' as env;
import '../network/supabase_client.dart';
import '../sync/sync_engine.dart';
import '../services/onboarding_service.dart';
import '../../shared/data/datasources/local/database_helper.dart';

@module
abstract class DIModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  @singleton
  Future<Database> get database async {
    final databaseHelper = DatabaseHelper();
    return await databaseHelper.database;
  }

  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  SupabaseClient get supabaseClient => SupabaseClientConfig.client;

  @preResolve
  @singleton
  Future<SyncEngine> get syncEngine async {
    final db = await database;
    return SyncEngine(
      supabaseClient: supabaseClient,
      database: db,
      connectivity: connectivity,
    );
  }

  @singleton
  Dio get dio {
    final dio = Dio();

    // Set timeout
    dio.options.connectTimeout =
        Duration(milliseconds: env.Environment.apiTimeout);
    dio.options.receiveTimeout =
        Duration(milliseconds: env.Environment.apiTimeout);

    // Add interceptors for logging, authentication, etc.
    if (env.Environment.enableLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return dio;
  }
}
