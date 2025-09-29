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
    await _simulateDelay();

    // Simulate different responses based on phone number
    if (phoneNumber.contains('999')) {
      return {
        'success': false,
        'message': 'Invalid phone number format',
        'error_code': 'INVALID_PHONE'
      };
    }

    if (phoneNumber.contains('000')) {
      return {
        'success': false,
        'message': 'Too many requests. Please try again later.',
        'error_code': 'RATE_LIMITED'
      };
    }

    return {
      'success': true,
      'message': 'OTP sent successfully',
      'data': {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'phone_number': phoneNumber,
        'otp_hash': 'mock_hash_${_random.nextInt(9999)}',
        'otp_expires_at': DateTime.now()
            .add(const Duration(minutes: 5))
            .millisecondsSinceEpoch,
        'is_active': true,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }
    };
  }

  /// Mock OTP verification
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    await _simulateDelay();

    // Simulate different responses based on OTP
    if (otp == '000000') {
      return {
        'success': false,
        'message': 'OTP has expired. Please request a new one.',
        'error_code': 'OTP_EXPIRED'
      };
    }

    if (otp == '999999') {
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
        'error_code': 'INVALID_OTP'
      };
    }

    // Mock successful verification
    final mockData = await _mockDataProvider.getAuthMockData();
    final userData = mockData['users']?[0] ?? {};

    return {
      'success': true,
      'message': 'Login successful',
      'data': {
        'user': {
          'id':
              userData['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
          'phone_number': phoneNumber,
          'is_active': true,
          'last_login': DateTime.now().millisecondsSinceEpoch,
          'created_at':
              userData['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        'access_token': 'mock_access_token_${_random.nextInt(999999)}',
        'refresh_token': 'mock_refresh_token_${_random.nextInt(999999)}',
        'expires_in': 3600, // 1 hour
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

    return {
      'success': true,
      'message': 'Token refreshed successfully',
      'data': {
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'phone_number': '+233123456789',
          'is_active': true,
          'last_login': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
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
