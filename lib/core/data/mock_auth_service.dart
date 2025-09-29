import 'dart:async';
import 'dart:math';

import '../constants/environment.dart' as env;
import 'mock_data_provider.dart';

class MockAuthService {
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  final MockDataProvider _mockDataProvider = MockDataProvider();
  final Random _random = Random();

  /// Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));
  }

  /// Mock OTP request
  Future<Map<String, dynamic>> requestOTP(String phoneNumber) async {
    print(
        'MockAuthService.requestOTP called with phone: $phoneNumber'); // Debug log
    await _simulateDelay();

    // Simulate different responses based on phone number
    if (phoneNumber.contains('999')) {
      print(
          'Phone number contains 999, returning invalid phone error'); // Debug log
      return {
        'success': false,
        'message': 'Invalid phone number format',
        'error_code': 'INVALID_PHONE'
      };
    }

    if (phoneNumber.contains('000')) {
      print(
          'Phone number contains 000, returning rate limit error'); // Debug log
      return {
        'success': false,
        'message': 'Too many requests. Please try again later.',
        'error_code': 'RATE_LIMITED'
      };
    }

    print('Phone number is valid, returning success response'); // Debug log
    final now = DateTime.now();
    return {
      'success': true,
      'message': 'OTP sent successfully',
      'data': {
        'id': 'user_${now.millisecondsSinceEpoch}',
        'phoneNumber': phoneNumber,
        'otpHash': 'mock_hash_${_random.nextInt(9999)}',
        'otp_expires_at':
            now.add(const Duration(minutes: 5)).millisecondsSinceEpoch,
        'is_active': true,
        'created_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      }
    };
  }

  /// Mock OTP verification
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    print(
        'MockAuthService.verifyOTP called with phone: $phoneNumber, otp: $otp'); // Debug log
    await _simulateDelay();

    // Simulate different responses based on OTP
    if (otp == '000000') {
      print('OTP is 000000, returning expired error'); // Debug log
      return {
        'success': false,
        'message': 'OTP has expired. Please request a new one.',
        'error_code': 'OTP_EXPIRED'
      };
    }

    if (otp == '999999') {
      print('OTP is 999999, returning invalid error'); // Debug log
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
        'error_code': 'INVALID_OTP'
      };
    }

    // For mock data, accept any 6-digit OTP except the special test cases
    if (otp.length != 6) {
      print('OTP length is not 6, returning invalid error'); // Debug log
      return {
        'success': false,
        'message': 'Invalid OTP format. Please enter a 6-digit code.',
        'error_code': 'INVALID_OTP'
      };
    }

    print('OTP is valid, returning success response'); // Debug log
    // Mock successful verification
    final now = DateTime.now();

    return {
      'success': true,
      'message': 'Login successful',
      'data': {
        'user': {
          'id': 'user_${now.millisecondsSinceEpoch}',
          'phoneNumber': phoneNumber,
          'otpHash': null,
          'is_active': true,
          'last_login': now.millisecondsSinceEpoch,
          'created_at': now.millisecondsSinceEpoch,
          'updated_at': now.millisecondsSinceEpoch,
        },
        'accessToken': 'mock_access_token_${_random.nextInt(999999)}',
        'refreshToken': 'mock_refresh_token_${_random.nextInt(999999)}',
        'expiresIn': 3600, // 1 hour
      }
    };
  }

  /// Mock token refresh
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    await _simulateDelay();

    if (refreshToken.contains('expired')) {
      return {
        'success': false,
        'message': 'Refresh token has expired. Please login again.',
        'error_code': 'REFRESH_TOKEN_EXPIRED'
      };
    }

    final now = DateTime.now();
    return {
      'success': true,
      'message': 'Token refreshed successfully',
      'data': {
        'user': {
          'id': 'user_${now.millisecondsSinceEpoch}',
          'phoneNumber': '+233123456789',
          'is_active': true,
          'last_login': now.toIso8601String(),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        'access_token': 'new_mock_access_token_${_random.nextInt(999999)}',
        'refresh_token': 'new_mock_refresh_token_${_random.nextInt(999999)}',
        'expires_in': 3600,
      }
    };
  }

  /// Mock logout
  Future<Map<String, dynamic>> logout(String accessToken) async {
    await _simulateDelay();

    return {
      'success': true,
      'message': 'Logged out successfully',
    };
  }

  /// Check if mock service should be used
  bool get shouldUseMockService => env.Environment.useMockData;
}
