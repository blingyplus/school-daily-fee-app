import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../constants/environment.dart' as env;
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
  Dio get dio {
    final dio = Dio();

    // Only set base URL if not using mock data
    if (!env.Environment.useMockData) {
      dio.options.baseUrl = env.Environment.apiBaseUrl;
      dio.options.connectTimeout =
          Duration(milliseconds: env.Environment.apiTimeout);
      dio.options.receiveTimeout =
          Duration(milliseconds: env.Environment.apiTimeout);

      // Add interceptors for logging, authentication, etc.
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }

    return dio;
  }
}
