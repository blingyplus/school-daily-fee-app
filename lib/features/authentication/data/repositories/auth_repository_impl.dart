import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/environment.dart' as env;
import '../../../../shared/domain/entities/user.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_supabase_datasource.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_verification_model.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthSupabaseDataSource supabaseDataSource;
  final AuthLocalDataSource localDataSource;
  final Connectivity connectivity;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<User> requestOTP(String phoneNumber) async {
    print(
        'AuthRepositoryImpl.requestOTP called with phone: $phoneNumber'); // Debug log

    // Check internet connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final request = OTPRequestModel(
        phoneNumber: phoneNumber,
        deviceId: await _getDeviceId(),
        appVersion: '1.0.0',
      );
      print('Created OTPRequestModel: ${request.toJson()}'); // Debug log

      UserModel userModel;
      if (env.Environment.useSupabase) {
        print('Using Supabase for OTP request'); // Debug log
        userModel = await supabaseDataSource.requestOTP(request);
      } else {
        print('Using mock/remote data source for OTP request'); // Debug log
        userModel = await remoteDataSource.requestOTP(request);
      }

      print('Received userModel from data source'); // Debug log
      final user = userModel.toEntity();

      // Save user data locally
      await localDataSource.saveUser(userModel);
      print('Saved user data locally'); // Debug log

      return user;
    } catch (e) {
      print('Error in requestOTP: $e'); // Debug log
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    // Check internet connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final request = OTPVerificationModel(
        phoneNumber: phoneNumber,
        otp: otp,
        deviceId: await _getDeviceId(),
      );

      AuthResponseModel authResponseModel;
      if (env.Environment.useSupabase) {
        print('Using Supabase for OTP verification'); // Debug log
        authResponseModel = await supabaseDataSource.verifyOTP(request);
      } else {
        print(
            'Using mock/remote data source for OTP verification'); // Debug log
        authResponseModel = await remoteDataSource.verifyOTP(request);
      }

      // Save user and tokens locally
      await localDataSource.saveUser(authResponseModel.user);
      await localDataSource.saveTokens(
        authResponseModel.accessToken,
        authResponseModel.refreshToken,
      );

      // Update last login
      await localDataSource.updateLastLogin(DateTime.now());

      return AuthResponse(
        user: authResponseModel.user.toEntity(),
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        expiresIn: authResponseModel.expiresIn,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      return userModel?.toEntity();
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await localDataSource.getAccessToken();
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      final token = await getAccessToken();
      return user != null && token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();

      // Clear local data first
      await localDataSource.clearUserData();

      // Then try to logout from server (don't fail if this fails)
      if (accessToken != null) {
        try {
          if (env.Environment.useSupabase) {
            await supabaseDataSource.logout(accessToken);
          } else {
            await remoteDataSource.logout(accessToken);
          }
        } catch (e) {
          // Log the error but don't throw
          print('Server logout failed: $e');
        }
      }
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout. Please try again.');
    }
  }

  @override
  Future<AuthResponse> refreshToken() async {
    // Check internet connectivity
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available. Please login again.');
      }

      AuthResponseModel authResponseModel;
      if (env.Environment.useSupabase) {
        authResponseModel = await supabaseDataSource.refreshToken(refreshToken);
      } else {
        authResponseModel = await remoteDataSource.refreshToken(refreshToken);
      }

      // Save new tokens
      await localDataSource.saveTokens(
        authResponseModel.accessToken,
        authResponseModel.refreshToken,
      );

      return AuthResponse(
        user: authResponseModel.user.toEntity(),
        accessToken: authResponseModel.accessToken,
        refreshToken: authResponseModel.refreshToken,
        expiresIn: authResponseModel.expiresIn,
      );
    } catch (e) {
      // If refresh fails, clear local data
      await localDataSource.clearUserData();
      throw Exception(e.toString());
    }
  }

  Future<String> _getDeviceId() async {
    // For now, return a placeholder device ID
    // In a real app, you would use device_info_plus or similar
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }
}
