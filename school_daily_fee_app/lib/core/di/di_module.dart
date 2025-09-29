import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../constants/environment.dart' as env;

@module
abstract class DIModule {
  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  @singleton
  Future<Database> get database async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, env.Environment.dbName);

    return await openDatabase(
      path,
      version: env.Environment.dbVersion,
      onCreate: (db, version) {
        // Database tables will be created here
        // We'll implement this in the next step
      },
    );
  }

  @singleton
  Connectivity get connectivity => Connectivity();

  @singleton
  Dio get dio {
    final dio = Dio();
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

    return dio;
  }
}
