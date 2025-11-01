import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_commerce/features/auth/domain/usecase/get_auth_state_changes.dart';
import 'package:e_commerce/features/auth/domain/usecase/register.dart';
import 'package:e_commerce/features/auth/domain/usecase/forgot_password.dart';
import 'package:e_commerce/features/auth/domain/usecase/google_sign_in.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:e_commerce/features/auth/domain/usecase/login.dart';
import 'package:e_commerce/features/auth/domain/usecase/logout.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetAuthStateChangesUseCase _getAuthStateChangesUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetAuthStateChangesUseCase getAuthStateChangesUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getAuthStateChangesUseCase = getAuthStateChangesUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        super(AuthInitial()) {
    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested); // Sẽ được cập nhật
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);

    _authSubscription = _getAuthStateChangesUseCase().listen((user) {
      add(AuthStateChanged(user));
    });
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  // State giờ đã chứa AppUser đầy đủ từ stream
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  // ĐÃ CẬP NHẬT: Handler cho đăng ký
  void _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _registerUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      phoneNumber: event.phoneNumber,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthForgotPasswordLoading());
    final result = await _forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthForgotPasswordSuccess()),
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _googleSignInUseCase();
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}