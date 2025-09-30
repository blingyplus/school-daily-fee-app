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
      print('🔍 Checking authentication status...');

      final isLoggedIn = await authRepository.isLoggedIn();
      print('🔍 Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        final user = await authRepository.getCurrentUser();
        if (user != null) {
          print('✅ User found, emitting AuthAuthenticated');
          emit(AuthAuthenticated(user: user));
        } else {
          print('❌ No user found, emitting AuthUnauthenticated');
          emit(const AuthUnauthenticated());
        }
      } else {
        print('❌ Not logged in, emitting AuthUnauthenticated');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Auth check error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔄 Login requested for phone: ${event.phoneNumber}');
    try {
      emit(const AuthLoading());
      print('📱 Requesting OTP...');

      await authRepository.requestOTP(event.phoneNumber);
      print('✅ OTP request completed successfully');

      emit(AuthOTPSent(phoneNumber: event.phoneNumber));
      print('📱 AuthOTPSent state emitted');
    } catch (e) {
      print('❌ Error in login request: $e');
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
      print('🔄 Logging out user...');

      await authRepository.logout();
      print('✅ Logout completed successfully');

      emit(const AuthUnauthenticated());
    } catch (e) {
      print('❌ Logout error: $e');
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
