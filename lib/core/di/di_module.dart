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
import '../services/profile_service.dart';
import '../../shared/data/datasources/local/database_helper.dart';
import '../../features/student_management/data/datasources/student_local_datasource.dart';
import '../../features/student_management/data/datasources/student_remote_datasource.dart';
import '../../features/student_management/data/repositories/student_repository_impl.dart';
import '../../features/student_management/domain/repositories/student_repository.dart';
import '../../features/student_management/domain/usecases/get_students_usecase.dart';
import '../../features/student_management/domain/usecases/search_students_usecase.dart';
import '../../features/student_management/domain/usecases/create_student_usecase.dart';
import '../../features/student_management/domain/usecases/update_student_usecase.dart';
import '../../features/student_management/domain/usecases/delete_student_usecase.dart';
import '../../features/student_management/presentation/bloc/student_bloc.dart';

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

  @preResolve
  @singleton
  Future<ProfileService> get profileService async {
    final db = await database;
    final sp = await sharedPreferences;
    return ProfileService(
      database: db,
      sharedPreferences: sp,
      supabaseClient: supabaseClient,
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

  // Student Management Dependencies
  @preResolve
  @singleton
  Future<StudentLocalDataSource> get studentLocalDataSource async {
    return StudentLocalDataSourceImpl(DatabaseHelper());
  }

  @singleton
  StudentRemoteDataSource get studentRemoteDataSource =>
      StudentRemoteDataSourceImpl(supabaseClient);

  @preResolve
  @singleton
  Future<StudentRepository> get studentRepository async {
    final localDataSource = await studentLocalDataSource;
    return StudentRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: studentRemoteDataSource,
    );
  }

  @preResolve
  @singleton
  Future<GetStudentsUseCase> get getStudentsUseCase async {
    final repository = await studentRepository;
    return GetStudentsUseCase(repository);
  }

  @preResolve
  @singleton
  Future<SearchStudentsUseCase> get searchStudentsUseCase async {
    final repository = await studentRepository;
    return SearchStudentsUseCase(repository);
  }

  @preResolve
  @singleton
  Future<CreateStudentUseCase> get createStudentUseCase async {
    final repository = await studentRepository;
    return CreateStudentUseCase(repository);
  }

  @preResolve
  @singleton
  Future<UpdateStudentUseCase> get updateStudentUseCase async {
    final repository = await studentRepository;
    return UpdateStudentUseCase(repository);
  }

  @preResolve
  @singleton
  Future<DeleteStudentUseCase> get deleteStudentUseCase async {
    final repository = await studentRepository;
    return DeleteStudentUseCase(repository);
  }

  @preResolve
  @singleton
  Future<StudentBloc> get studentBloc async {
    final getStudentsUseCase = await this.getStudentsUseCase;
    final searchStudentsUseCase = await this.searchStudentsUseCase;
    final createStudentUseCase = await this.createStudentUseCase;
    final updateStudentUseCase = await this.updateStudentUseCase;
    final deleteStudentUseCase = await this.deleteStudentUseCase;

    return StudentBloc(
      getStudentsUseCase: getStudentsUseCase,
      searchStudentsUseCase: searchStudentsUseCase,
      createStudentUseCase: createStudentUseCase,
      updateStudentUseCase: updateStudentUseCase,
      deleteStudentUseCase: deleteStudentUseCase,
    );
  }
}
