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
import 'package:skuupay/core/di/di_module.dart' as _i12;
import 'package:skuupay/features/authentication/data/datasources/auth_local_datasource.dart'
    as _i7;
import 'package:skuupay/features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i8;
import 'package:skuupay/features/authentication/data/repositories/auth_repository_impl.dart'
    as _i10;
import 'package:skuupay/features/authentication/domain/repositories/auth_repository.dart'
    as _i9;
import 'package:skuupay/features/authentication/presentation/bloc/auth_bloc.dart'
    as _i11;
import 'package:shared_preferences/shared_preferences.dart' as _i6;
import 'package:sqflite/sqflite.dart' as _i4;

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
    await gh.singletonAsync<_i6.SharedPreferences>(
      () => dIModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i7.AuthLocalDataSource>(() => _i7.AuthLocalDataSourceImpl(
          sharedPreferences: gh<_i6.SharedPreferences>(),
          database: gh<_i4.Database>(),
        ));
    gh.lazySingleton<_i8.AuthRemoteDataSource>(
        () => _i8.AuthRemoteDataSourceImpl(dio: gh<_i5.Dio>()));
    gh.lazySingleton<_i9.AuthRepository>(() => _i10.AuthRepositoryImpl(
          remoteDataSource: gh<_i8.AuthRemoteDataSource>(),
          localDataSource: gh<_i7.AuthLocalDataSource>(),
          connectivity: gh<_i3.Connectivity>(),
        ));
    gh.factory<_i11.AuthBloc>(
        () => _i11.AuthBloc(authRepository: gh<_i9.AuthRepository>()));
    return this;
  }
}

class _$DIModule extends _i12.DIModule {}
