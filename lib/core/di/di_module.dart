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
import '../../features/student_management/domain/usecases/get_student_fee_config_usecase.dart';
import '../../features/student_management/domain/usecases/update_student_fee_config_usecase.dart';
import '../../features/student_management/presentation/bloc/student_bloc.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/domain/usecases/get_attendance_records_usecase.dart';
import '../../features/attendance/domain/usecases/get_class_attendance_usecase.dart';
import '../../features/attendance/domain/usecases/mark_attendance_usecase.dart';
import '../../features/attendance/domain/usecases/bulk_mark_attendance_usecase.dart';
import '../../features/fee_collection/presentation/bloc/fee_collection_bloc.dart';
import '../../features/fee_collection/domain/repositories/fee_collection_repository.dart';
import '../../features/fee_collection/data/repositories/fee_collection_repository_impl.dart';
import '../../features/fee_collection/data/datasources/fee_collection_local_datasource.dart';
import '../../features/fee_collection/data/datasources/fee_collection_remote_datasource.dart';
import '../../features/fee_collection/domain/usecases/get_fee_collections_usecase.dart';
import '../../features/fee_collection/domain/usecases/get_student_fee_history_usecase.dart';
import '../../features/fee_collection/domain/usecases/collect_fee_usecase.dart';
import '../../features/fee_collection/domain/usecases/generate_receipt_number_usecase.dart';
import '../../features/fee_collection/domain/usecases/check_student_payment_status_usecase.dart';

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
    final db = await database;
    return StudentLocalDataSourceImpl(db);
  }

  @singleton
  StudentRemoteDataSource get studentRemoteDataSource =>
      StudentRemoteDataSourceImpl(supabaseClient);

  @preResolve
  @singleton
  Future<StudentRepository> get studentRepository async {
    final localDataSource = await studentLocalDataSource;
    final sync = await syncEngine;
    return StudentRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: studentRemoteDataSource,
      syncEngine: sync,
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
  Future<GetStudentFeeConfigUseCase> get getStudentFeeConfigUseCase async {
    final repository = await studentRepository;
    return GetStudentFeeConfigUseCase(repository);
  }

  @preResolve
  @singleton
  Future<UpdateStudentFeeConfigUseCase>
      get updateStudentFeeConfigUseCase async {
    final repository = await studentRepository;
    return UpdateStudentFeeConfigUseCase(repository);
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

  // Attendance Management Dependencies
  @preResolve
  @singleton
  Future<AttendanceLocalDataSource> get attendanceLocalDataSource async {
    return AttendanceLocalDataSourceImpl(DatabaseHelper());
  }

  @singleton
  AttendanceRemoteDataSource get attendanceRemoteDataSource =>
      AttendanceRemoteDataSourceImpl(supabaseClient);

  @preResolve
  @singleton
  Future<AttendanceRepository> get attendanceRepository async {
    final localDataSource = await attendanceLocalDataSource;
    final sync = await syncEngine;
    return AttendanceRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: attendanceRemoteDataSource,
      syncEngine: sync,
    );
  }

  @preResolve
  @singleton
  Future<GetAttendanceRecordsUseCase> get getAttendanceRecordsUseCase async {
    final repository = await attendanceRepository;
    return GetAttendanceRecordsUseCase(repository);
  }

  @preResolve
  @singleton
  Future<GetClassAttendanceUseCase> get getClassAttendanceUseCase async {
    final repository = await attendanceRepository;
    return GetClassAttendanceUseCase(repository);
  }

  @preResolve
  @singleton
  Future<MarkAttendanceUseCase> get markAttendanceUseCase async {
    final repository = await attendanceRepository;
    return MarkAttendanceUseCase(repository);
  }

  @preResolve
  @singleton
  Future<BulkMarkAttendanceUseCase> get bulkMarkAttendanceUseCase async {
    final repository = await attendanceRepository;
    return BulkMarkAttendanceUseCase(repository);
  }

  @preResolve
  @singleton
  Future<AttendanceBloc> get attendanceBloc async {
    final getAttendanceRecordsUseCase = await this.getAttendanceRecordsUseCase;
    final getClassAttendanceUseCase = await this.getClassAttendanceUseCase;
    final markAttendanceUseCase = await this.markAttendanceUseCase;
    final bulkMarkAttendanceUseCase = await this.bulkMarkAttendanceUseCase;

    return AttendanceBloc(
      getAttendanceRecordsUseCase: getAttendanceRecordsUseCase,
      getClassAttendanceUseCase: getClassAttendanceUseCase,
      markAttendanceUseCase: markAttendanceUseCase,
      bulkMarkAttendanceUseCase: bulkMarkAttendanceUseCase,
    );
  }

  // Fee Collection Management Dependencies
  @preResolve
  @singleton
  Future<FeeCollectionLocalDataSource> get feeCollectionLocalDataSource async {
    return FeeCollectionLocalDataSourceImpl(DatabaseHelper());
  }

  @singleton
  FeeCollectionRemoteDataSource get feeCollectionRemoteDataSource =>
      FeeCollectionRemoteDataSourceImpl(supabaseClient);

  @preResolve
  @singleton
  Future<FeeCollectionRepository> get feeCollectionRepository async {
    final localDataSource = await feeCollectionLocalDataSource;
    final sync = await syncEngine;
    return FeeCollectionRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: feeCollectionRemoteDataSource,
      syncEngine: sync,
    );
  }

  @preResolve
  @singleton
  Future<GetFeeCollectionsUseCase> get getFeeCollectionsUseCase async {
    final repository = await feeCollectionRepository;
    return GetFeeCollectionsUseCase(repository);
  }

  @preResolve
  @singleton
  Future<GetStudentFeeHistoryUseCase> get getStudentFeeHistoryUseCase async {
    final repository = await feeCollectionRepository;
    return GetStudentFeeHistoryUseCase(repository);
  }

  @preResolve
  @singleton
  Future<CollectFeeUseCase> get collectFeeUseCase async {
    final repository = await feeCollectionRepository;
    return CollectFeeUseCase(repository);
  }

  @preResolve
  @singleton
  Future<GenerateReceiptNumberUseCase> get generateReceiptNumberUseCase async {
    final repository = await feeCollectionRepository;
    return GenerateReceiptNumberUseCase(repository);
  }

  @preResolve
  @singleton
  Future<CheckStudentPaymentStatusUseCase>
      get checkStudentPaymentStatusUseCase async {
    final repository = await feeCollectionRepository;
    return CheckStudentPaymentStatusUseCase(repository);
  }

  @preResolve
  @singleton
  Future<FeeCollectionBloc> get feeCollectionBloc async {
    final getFeeCollectionsUseCase = await this.getFeeCollectionsUseCase;
    final getStudentFeeHistoryUseCase = await this.getStudentFeeHistoryUseCase;
    final collectFeeUseCase = await this.collectFeeUseCase;
    final generateReceiptNumberUseCase =
        await this.generateReceiptNumberUseCase;

    return FeeCollectionBloc(
      getFeeCollectionsUseCase: getFeeCollectionsUseCase,
      getStudentFeeHistoryUseCase: getStudentFeeHistoryUseCase,
      collectFeeUseCase: collectFeeUseCase,
      generateReceiptNumberUseCase: generateReceiptNumberUseCase,
    );
  }
}
