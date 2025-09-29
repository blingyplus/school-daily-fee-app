import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/environment.dart' as env;
import '../../../../core/data/mock_auth_service.dart';
import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_verification_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> requestOTP(OTPRequestModel request);
  Future<AuthResponseModel> verifyOTP(OTPVerificationModel request);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout(String accessToken);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final MockAuthService _mockAuthService = MockAuthService();

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> requestOTP(OTPRequestModel request) async {
    // Use mock service if enabled
    if (env.Environment.useMockData) {
      final mockResponse =
          await _mockAuthService.requestOTP(request.phoneNumber);

      if (mockResponse['success'] == true) {
        return UserModel.fromJson(mockResponse['data']);
      } else {
        throw Exception(mockResponse['message'] ?? 'Failed to request OTP');
      }
    }

    // Real API call
    try {
      final response = await dio.post(
        '/auth/request-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to request OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Invalid phone number');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Too many requests. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to request OTP. Please try again.');
      }
    }
  }

  @override
  Future<AuthResponseModel> verifyOTP(OTPVerificationModel request) async {
    // Use mock service if enabled
    if (env.Environment.useMockData) {
      final mockResponse =
          await _mockAuthService.verifyOTP(request.phoneNumber, request.otp);

      if (mockResponse['success'] == true) {
        return AuthResponseModel.fromJson(mockResponse['data']);
      } else {
        throw Exception(mockResponse['message'] ?? 'Failed to verify OTP');
      }
    }

    // Real API call
    try {
      final response = await dio.post(
        '/auth/verify-otp',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to verify OTP',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Invalid OTP');
      } else if (e.response?.statusCode == 401) {
        throw Exception('OTP has expired. Please request a new one.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to verify OTP. Please try again.');
      }
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return AuthResponseModel.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['message'] ?? 'Failed to refresh token',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Refresh token has expired. Please login again.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
            'Connection timeout. Please check your internet connection.');
      } else {
        throw Exception('Failed to refresh token. Please try again.');
      }
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    // Use mock service if enabled
    if (env.Environment.useMockData) {
      await _mockAuthService.logout(accessToken);
      return;
    }

    // Real API call
    try {
      await dio.post(
        '/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      // Logout should not fail even if the server request fails
      // The local session will be cleared regardless
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Silently handle timeout errors
      } else {
        // Log the error but don't throw
        print('Logout request failed: ${e.message}');
      }
    }
  }
}
