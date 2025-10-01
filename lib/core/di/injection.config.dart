// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i10;
import 'package:dio/dio.dart' as _i14;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i29;
import 'package:skuupay/core/di/di_module.dart' as _i46;
import 'package:skuupay/core/services/onboarding_service.dart' as _i41;
import 'package:skuupay/core/services/profile_service.dart' as _i27;
import 'package:skuupay/core/services/school_service.dart' as _i42;
import 'package:skuupay/core/sync/sync_engine.dart' as _i35;
import 'package:skuupay/features/attendance/data/datasources/attendance_local_datasource.dart'
    as _i4;
import 'package:skuupay/features/attendance/data/datasources/attendance_remote_datasource.dart'
    as _i5;
import 'package:skuupay/features/attendance/domain/repositories/attendance_repository.dart'
    as _i6;
import 'package:skuupay/features/attendance/domain/usecases/bulk_mark_attendance_usecase.dart'
    as _i7;
import 'package:skuupay/features/attendance/domain/usecases/get_attendance_records_usecase.dart'
    as _i20;
import 'package:skuupay/features/attendance/domain/usecases/get_class_attendance_usecase.dart'
    as _i21;
import 'package:skuupay/features/attendance/domain/usecases/mark_attendance_usecase.dart'
    as _i26;
import 'package:skuupay/features/attendance/presentation/bloc/attendance_bloc.dart'
    as _i3;
import 'package:skuupay/features/authentication/data/datasources/auth_local_datasource.dart'
    as _i38;
import 'package:skuupay/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i39;
import 'package:skuupay/features/authentication/data/datasources/auth_supabase_datasource.dart'
    as _i40;
import 'package:skuupay/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i44;
import 'package:skuupay/features/authentication/domain/repositories/auth_repository.dart'
    as _i43;
import 'package:skuupay/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i45;
import 'package:skuupay/features/fee_collection/data/datasources/fee_collection_local_datasource.dart'
    as _i16;
import 'package:skuupay/features/fee_collection/data/datasources/fee_collection_remote_datasource.dart'
    as _i17;
import 'package:skuupay/features/fee_collection/domain/repositories/fee_collection_repository.dart'
    as _i18;
import 'package:skuupay/features/fee_collection/domain/usecases/check_student_payment_status_usecase.dart'
    as _i8;
import 'package:skuupay/features/fee_collection/domain/usecases/collect_fee_usecase.dart'
    as _i9;
import 'package:skuupay/features/fee_collection/domain/usecases/generate_receipt_number_usecase.dart'
    as _i19;
import 'package:skuupay/features/fee_collection/domain/usecases/get_fee_collections_usecase.dart'
    as _i22;
import 'package:skuupay/features/fee_collection/domain/usecases/get_student_fee_history_usecase.dart'
    as _i24;
import 'package:skuupay/features/fee_collection/presentation/bloc/fee_collection_bloc.dart'
    as _i15;
import 'package:skuupay/features/student_management/data/datasources/student_local_datasource.dart'
    as _i31;
import 'package:skuupay/features/student_management/data/datasources/student_remote_datasource.dart'
    as _i32;
import 'package:skuupay/features/student_management/domain/repositories/student_repository.dart'
    as _i33;
import 'package:skuupay/features/student_management/domain/usecases/create_student_usecase.dart'
    as _i11;
import 'package:skuupay/features/student_management/domain/usecases/delete_student_usecase.dart'
    as _i13;
import 'package:skuupay/features/student_management/domain/usecases/get_student_fee_config_usecase.dart'
    as _i23;
import 'package:skuupay/features/student_management/domain/usecases/get_students_usecase.dart'
    as _i25;
import 'package:skuupay/features/student_management/domain/usecases/search_students_usecase.dart'
    as _i28;
import 'package:skuupay/features/student_management/domain/usecases/update_student_fee_config_usecase.dart'
    as _i36;
import 'package:skuupay/features/student_management/domain/usecases/update_student_usecase.dart'
    as _i37;
import 'package:skuupay/features/student_management/presentation/bloc/student_bloc.dart'
    as _i30;
import 'package:sqflite/sqflite.dart' as _i12;
import 'package:supabase_flutter/supabase_flutter.dart' as _i34;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final dIModule = _$DIModule();
    await gh.singletonAsync<_i3.AttendanceBloc>(
      () => dIModule.attendanceBloc,
      preResolve: true,
    );
    await gh.singletonAsync<_i4.AttendanceLocalDataSource>(
      () => dIModule.attendanceLocalDataSource,
      preResolve: true,
    );
    gh.singleton<_i5.AttendanceRemoteDataSource>(
        () => dIModule.attendanceRemoteDataSource);
    await gh.singletonAsync<_i6.AttendanceRepository>(
      () => dIModule.attendanceRepository,
      preResolve: true,
    );
    await gh.singletonAsync<_i7.BulkMarkAttendanceUseCase>(
      () => dIModule.bulkMarkAttendanceUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i8.CheckStudentPaymentStatusUseCase>(
      () => dIModule.checkStudentPaymentStatusUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i9.CollectFeeUseCase>(
      () => dIModule.collectFeeUseCase,
      preResolve: true,
    );
    gh.singleton<_i10.Connectivity>(() => dIModule.connectivity);
    await gh.singletonAsync<_i11.CreateStudentUseCase>(
      () => dIModule.createStudentUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i12.Database>(
      () => dIModule.database,
      preResolve: true,
    );
    await gh.singletonAsync<_i13.DeleteStudentUseCase>(
      () => dIModule.deleteStudentUseCase,
      preResolve: true,
    );
    gh.singleton<_i14.Dio>(() => dIModule.dio);
    await gh.singletonAsync<_i15.FeeCollectionBloc>(
      () => dIModule.feeCollectionBloc,
      preResolve: true,
    );
    await gh.singletonAsync<_i16.FeeCollectionLocalDataSource>(
      () => dIModule.feeCollectionLocalDataSource,
      preResolve: true,
    );
    gh.singleton<_i17.FeeCollectionRemoteDataSource>(
        () => dIModule.feeCollectionRemoteDataSource);
    await gh.singletonAsync<_i18.FeeCollectionRepository>(
      () => dIModule.feeCollectionRepository,
      preResolve: true,
    );
    await gh.singletonAsync<_i19.GenerateReceiptNumberUseCase>(
      () => dIModule.generateReceiptNumberUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i20.GetAttendanceRecordsUseCase>(
      () => dIModule.getAttendanceRecordsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i21.GetClassAttendanceUseCase>(
      () => dIModule.getClassAttendanceUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i22.GetFeeCollectionsUseCase>(
      () => dIModule.getFeeCollectionsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i23.GetStudentFeeConfigUseCase>(
      () => dIModule.getStudentFeeConfigUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i24.GetStudentFeeHistoryUseCase>(
      () => dIModule.getStudentFeeHistoryUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i25.GetStudentsUseCase>(
      () => dIModule.getStudentsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i26.MarkAttendanceUseCase>(
      () => dIModule.markAttendanceUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i27.ProfileService>(
      () => dIModule.profileService,
      preResolve: true,
    );
    await gh.singletonAsync<_i28.SearchStudentsUseCase>(
      () => dIModule.searchStudentsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i29.SharedPreferences>(
      () => dIModule.sharedPreferences,
      preResolve: true,
    );
    await gh.singletonAsync<_i30.StudentBloc>(
      () => dIModule.studentBloc,
      preResolve: true,
    );
    await gh.singletonAsync<_i31.StudentLocalDataSource>(
      () => dIModule.studentLocalDataSource,
      preResolve: true,
    );
    gh.singleton<_i32.StudentRemoteDataSource>(
        () => dIModule.studentRemoteDataSource);
    await gh.singletonAsync<_i33.StudentRepository>(
      () => dIModule.studentRepository,
      preResolve: true,
    );
    gh.singleton<_i34.SupabaseClient>(() => dIModule.supabaseClient);
    await gh.singletonAsync<_i35.SyncEngine>(
      () => dIModule.syncEngine,
      preResolve: true,
    );
    await gh.singletonAsync<_i36.UpdateStudentFeeConfigUseCase>(
      () => dIModule.updateStudentFeeConfigUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i37.UpdateStudentUseCase>(
      () => dIModule.updateStudentUseCase,
      preResolve: true,
    );
    gh.lazySingleton<_i38.AuthLocalDataSource>(
        () => _i38.AuthLocalDataSourceImpl(
              sharedPreferences: gh<_i29.SharedPreferences>(),
              database: gh<_i12.Database>(),
            ));
    gh.lazySingleton<_i39.AuthRemoteDataSource>(
        () => _i39.AuthRemoteDataSourceImpl(dio: gh<_i14.Dio>()));
    gh.lazySingleton<_i40.AuthSupabaseDataSource>(() =>
        _i40.AuthSupabaseDataSourceImpl(
            supabaseClient: gh<_i34.SupabaseClient>()));
    gh.singleton<_i41.OnboardingService>(() => _i41.OnboardingService(
          database: gh<_i12.Database>(),
          sharedPreferences: gh<_i29.SharedPreferences>(),
        ));
    gh.singleton<_i42.SchoolService>(() => _i42.SchoolService(
          database: gh<_i12.Database>(),
          supabaseClient: gh<_i34.SupabaseClient>(),
          syncEngine: gh<_i35.SyncEngine>(),
        ));
    gh.lazySingleton<_i43.AuthRepository>(() => _i44.AuthRepositoryImpl(
          remoteDataSource: gh<_i39.AuthRemoteDataSource>(),
          supabaseDataSource: gh<_i40.AuthSupabaseDataSource>(),
          localDataSource: gh<_i38.AuthLocalDataSource>(),
          connectivity: gh<_i10.Connectivity>(),
        ));
    gh.factory<_i45.AuthBloc>(
        () => _i45.AuthBloc(authRepository: gh<_i43.AuthRepository>()));
    return this;
  }
}

class _$DIModule extends _i46.DIModule {}
