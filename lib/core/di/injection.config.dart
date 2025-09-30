// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i3;
import 'package:dio/dio.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i11;
import 'package:skuupay/core/di/di_module.dart' as _i27;
import 'package:skuupay/core/services/onboarding_service.dart' as _i22;
import 'package:skuupay/core/services/profile_service.dart' as _i9;
import 'package:skuupay/core/services/school_service.dart' as _i23;
import 'package:skuupay/core/sync/sync_engine.dart' as _i17;
import 'package:skuupay/features/authentication/data/datasources/auth_local_datasource.dart'
    as _i19;
import 'package:skuupay/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i20;
import 'package:skuupay/features/authentication/data/datasources/auth_supabase_datasource.dart'
    as _i21;
import 'package:skuupay/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i25;
import 'package:skuupay/features/authentication/domain/repositories/auth_repository.dart'
    as _i24;
import 'package:skuupay/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i26;
import 'package:skuupay/features/student_management/data/datasources/student_local_datasource.dart'
    as _i13;
import 'package:skuupay/features/student_management/data/datasources/student_remote_datasource.dart'
    as _i14;
import 'package:skuupay/features/student_management/domain/repositories/student_repository.dart'
    as _i15;
import 'package:skuupay/features/student_management/domain/usecases/create_student_usecase.dart'
    as _i4;
import 'package:skuupay/features/student_management/domain/usecases/delete_student_usecase.dart'
    as _i6;
import 'package:skuupay/features/student_management/domain/usecases/get_students_usecase.dart'
    as _i8;
import 'package:skuupay/features/student_management/domain/usecases/search_students_usecase.dart'
    as _i10;
import 'package:skuupay/features/student_management/domain/usecases/update_student_usecase.dart'
    as _i18;
import 'package:skuupay/features/student_management/presentation/bloc/student_bloc.dart'
    as _i12;
import 'package:sqflite/sqflite.dart' as _i5;
import 'package:supabase_flutter/supabase_flutter.dart' as _i16;

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
    gh.singleton<_i3.Connectivity>(() => dIModule.connectivity);
    await gh.singletonAsync<_i4.CreateStudentUseCase>(
      () => dIModule.createStudentUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i5.Database>(
      () => dIModule.database,
      preResolve: true,
    );
    await gh.singletonAsync<_i6.DeleteStudentUseCase>(
      () => dIModule.deleteStudentUseCase,
      preResolve: true,
    );
    gh.singleton<_i7.Dio>(() => dIModule.dio);
    await gh.singletonAsync<_i8.GetStudentsUseCase>(
      () => dIModule.getStudentsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i9.ProfileService>(
      () => dIModule.profileService,
      preResolve: true,
    );
    await gh.singletonAsync<_i10.SearchStudentsUseCase>(
      () => dIModule.searchStudentsUseCase,
      preResolve: true,
    );
    await gh.singletonAsync<_i11.SharedPreferences>(
      () => dIModule.sharedPreferences,
      preResolve: true,
    );
    await gh.singletonAsync<_i12.StudentBloc>(
      () => dIModule.studentBloc,
      preResolve: true,
    );
    await gh.singletonAsync<_i13.StudentLocalDataSource>(
      () => dIModule.studentLocalDataSource,
      preResolve: true,
    );
    gh.singleton<_i14.StudentRemoteDataSource>(
        () => dIModule.studentRemoteDataSource);
    await gh.singletonAsync<_i15.StudentRepository>(
      () => dIModule.studentRepository,
      preResolve: true,
    );
    gh.singleton<_i16.SupabaseClient>(() => dIModule.supabaseClient);
    await gh.singletonAsync<_i17.SyncEngine>(
      () => dIModule.syncEngine,
      preResolve: true,
    );
    await gh.singletonAsync<_i18.UpdateStudentUseCase>(
      () => dIModule.updateStudentUseCase,
      preResolve: true,
    );
    gh.lazySingleton<_i19.AuthLocalDataSource>(
        () => _i19.AuthLocalDataSourceImpl(
              sharedPreferences: gh<_i11.SharedPreferences>(),
              database: gh<_i5.Database>(),
            ));
    gh.lazySingleton<_i20.AuthRemoteDataSource>(
        () => _i20.AuthRemoteDataSourceImpl(dio: gh<_i7.Dio>()));
    gh.lazySingleton<_i21.AuthSupabaseDataSource>(() =>
        _i21.AuthSupabaseDataSourceImpl(
            supabaseClient: gh<_i16.SupabaseClient>()));
    gh.singleton<_i22.OnboardingService>(() => _i22.OnboardingService(
          database: gh<_i5.Database>(),
          sharedPreferences: gh<_i11.SharedPreferences>(),
        ));
    gh.singleton<_i23.SchoolService>(() => _i23.SchoolService(
          database: gh<_i5.Database>(),
          supabaseClient: gh<_i16.SupabaseClient>(),
          syncEngine: gh<_i17.SyncEngine>(),
        ));
    gh.lazySingleton<_i24.AuthRepository>(() => _i25.AuthRepositoryImpl(
          remoteDataSource: gh<_i20.AuthRemoteDataSource>(),
          supabaseDataSource: gh<_i21.AuthSupabaseDataSource>(),
          localDataSource: gh<_i19.AuthLocalDataSource>(),
          connectivity: gh<_i3.Connectivity>(),
        ));
    gh.factory<_i26.AuthBloc>(
        () => _i26.AuthBloc(authRepository: gh<_i24.AuthRepository>()));
    return this;
  }
}

class _$DIModule extends _i27.DIModule {}
