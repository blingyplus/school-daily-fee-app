import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/auth_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_verification_model.dart';
import '../models/user_model.dart';

abstract class AuthSupabaseDataSource {
  Future<UserModel> requestOTP(OTPRequestModel request);
  Future<AuthResponseModel> verifyOTP(OTPVerificationModel request);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<void> logout(String accessToken);
}

@LazySingleton(as: AuthSupabaseDataSource)
class AuthSupabaseDataSourceImpl implements AuthSupabaseDataSource {
  final SupabaseClient supabaseClient;

  AuthSupabaseDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> requestOTP(OTPRequestModel request) async {
    try {
      // For now, we'll use Supabase's built-in phone auth
      // In a real implementation, you might want to use a custom OTP service
      await supabaseClient.auth.signInWithOtp(
        phone: request.phoneNumber,
      );

      // Create a UserModel for the OTP request
      final now = DateTime.now();
      return UserModel(
        id: 'temp_${now.millisecondsSinceEpoch}',
        phoneNumber: request.phoneNumber,
        otpHash: null, // Supabase handles this internally
        otpExpiresAt:
            now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        isActive: true,
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      );
    } catch (e) {
      if (e is AuthException) {
        throw Exception(e.message);
      }
      throw Exception('Failed to request OTP: $e');
    }
  }

  @override
  Future<AuthResponseModel> verifyOTP(OTPVerificationModel request) async {
    try {
      final response = await supabaseClient.auth.verifyOTP(
        phone: request.phoneNumber,
        token: request.otp,
        type: OtpType.sms,
      );

      if (response.user != null && response.session != null) {
        final userModel = UserModel(
          id: response.user!.id,
          phoneNumber: request.phoneNumber,
          otpHash: null,
          lastLogin: DateTime.now().millisecondsSinceEpoch,
          isActive: true,
          createdAt:
              DateTime.parse(response.user!.createdAt).millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        return AuthResponseModel(
          user: userModel,
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          expiresIn: response.session!.expiresIn ?? 3600,
        );
      } else {
        throw Exception('Invalid OTP or verification failed');
      }
    } catch (e) {
      if (e is AuthException) {
        if (e.message.contains('expired')) {
          throw Exception('OTP has expired. Please request a new one.');
        } else if (e.message.contains('invalid')) {
          throw Exception('Invalid OTP. Please try again.');
        }
        throw Exception(e.message);
      }
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await supabaseClient.auth.refreshSession();

      if (response.user != null && response.session != null) {
        final userModel = UserModel(
          id: response.user!.id,
          phoneNumber: response.user!.phone ?? '',
          otpHash: null,
          lastLogin: DateTime.now().millisecondsSinceEpoch,
          isActive: true,
          createdAt:
              DateTime.parse(response.user!.createdAt).millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );

        return AuthResponseModel(
          user: userModel,
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          expiresIn: response.session!.expiresIn ?? 3600,
        );
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      if (e is AuthException) {
        throw Exception('Refresh token has expired. Please login again.');
      }
      throw Exception('Failed to refresh token: $e');
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      // Logout should not fail even if the server request fails
      // The local session will be cleared regardless
      print('Logout request failed: $e');
    }
  }
}
