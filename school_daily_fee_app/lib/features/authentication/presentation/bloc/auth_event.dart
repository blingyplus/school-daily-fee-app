import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;

  const AuthLoginRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOTPVerificationRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthOTPVerificationRequested({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthTokenRefreshRequested extends AuthEvent {
  const AuthTokenRefreshRequested();
}

class AuthOTPResendRequested extends AuthEvent {
  final String phoneNumber;

  const AuthOTPResendRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
