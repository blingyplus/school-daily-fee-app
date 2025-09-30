// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i3;
import 'package:dio/dio.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i7;
import 'package:skuupay/core/di/di_module.dart' as _i17;
import 'package:skuupay/core/services/onboarding_service.dart' as _i6;
import 'package:skuupay/core/services/school_service.dart' as _i13;
import 'package:skuupay/core/sync/sync_engine.dart' as _i9;
import 'package:skuupay/features/authentication/data/datasources/auth_local_datasource.dart'
    as _i10;
import 'package:skuupay/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i11;
import 'package:skuupay/features/authentication/data/datasources/auth_supabase_datasource.dart'
    as _i12;
import 'package:skuupay/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i15;
import 'package:skuupay/features/authentication/domain/repositories/auth_repository.dart'
    as _i14;
import 'package:skuupay/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i16;
import 'package:sqflite/sqflite.dart' as _i4;
import 'package:supabase_flutter/supabase_flutter.dart' as _i8;

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
    await gh.singletonAsync<_i4.Database>(
      () => dIModule.database,
      preResolve: true,
    );
    gh.singleton<_i5.Dio>(() => dIModule.dio);
    gh.singleton<_i6.OnboardingService>(
        () => _i6.OnboardingService(database: gh<_i4.Database>()));
    await gh.singletonAsync<_i7.SharedPreferences>(
      () => dIModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i8.SupabaseClient>(() => dIModule.supabaseClient);
    await gh.singletonAsync<_i9.SyncEngine>(
      () => dIModule.syncEngine,
      preResolve: true,
    );
    gh.lazySingleton<_i10.AuthLocalDataSource>(
        () => _i10.AuthLocalDataSourceImpl(
              sharedPreferences: gh<_i7.SharedPreferences>(),
              database: gh<_i4.Database>(),
            ));
    gh.lazySingleton<_i11.AuthRemoteDataSource>(
        () => _i11.AuthRemoteDataSourceImpl(dio: gh<_i5.Dio>()));
    gh.lazySingleton<_i12.AuthSupabaseDataSource>(() =>
        _i12.AuthSupabaseDataSourceImpl(
            supabaseClient: gh<_i8.SupabaseClient>()));
    gh.singleton<_i13.SchoolService>(() => _i13.SchoolService(
          database: gh<_i4.Database>(),
          supabaseClient: gh<_i8.SupabaseClient>(),
          syncEngine: gh<_i9.SyncEngine>(),
        ));
    gh.lazySingleton<_i14.AuthRepository>(() => _i15.AuthRepositoryImpl(
          remoteDataSource: gh<_i11.AuthRemoteDataSource>(),
          supabaseDataSource: gh<_i12.AuthSupabaseDataSource>(),
          localDataSource: gh<_i10.AuthLocalDataSource>(),
          connectivity: gh<_i3.Connectivity>(),
        ));
    gh.factory<_i16.AuthBloc>(
        () => _i16.AuthBloc(authRepository: gh<_i14.AuthRepository>()));
    return this;
  }
}

class _$DIModule extends _i17.DIModule {}
