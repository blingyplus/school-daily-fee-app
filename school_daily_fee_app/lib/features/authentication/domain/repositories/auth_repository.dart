import 'dart:async';
import '../../../../shared/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> requestOTP(String phoneNumber);
  Future<AuthResponse> verifyOTP(String phoneNumber, String otp);
  Future<User?> getCurrentUser();
  Future<String?> getAccessToken();
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<AuthResponse> refreshToken();
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });
}
