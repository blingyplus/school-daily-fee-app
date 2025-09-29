import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthOTPVerificationRequested>(_onAuthOTPVerificationRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
    on<AuthOTPResendRequested>(_onAuthOTPResendRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final isLoggedIn = await authRepository.isLoggedIn();

      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print(
        '_onAuthLoginRequested called with phone: ${event.phoneNumber}'); // Debug log
    try {
      emit(const AuthLoading());
      print('AuthLoading emitted'); // Debug log

      await authRepository.requestOTP(event.phoneNumber);
      print('OTP request completed successfully'); // Debug log

      emit(AuthOTPSent(phoneNumber: event.phoneNumber));
      print('AuthOTPSent emitted'); // Debug log
    } catch (e) {
      print('Error in _onAuthLoginRequested: $e'); // Debug log
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthOTPVerificationRequested(
    AuthOTPVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final authResponse = await authRepository.verifyOTP(
        event.phoneNumber,
        event.otp,
      );

      emit(AuthAuthenticated(user: authResponse.user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      await authRepository.logout();

      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final authResponse = await authRepository.refreshToken();

      emit(AuthAuthenticated(user: authResponse.user));
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthOTPResendRequested(
    AuthOTPResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      await authRepository.requestOTP(event.phoneNumber);

      emit(AuthOTPResent(phoneNumber: event.phoneNumber));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
