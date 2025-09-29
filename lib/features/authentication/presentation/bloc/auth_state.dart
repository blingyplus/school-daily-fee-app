import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthOTPSent extends AuthState {
  final String phoneNumber;

  const AuthOTPSent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthOTPResent extends AuthState {
  final String phoneNumber;

  const AuthOTPResent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
