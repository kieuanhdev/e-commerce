import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:e_commerce/features/auth/domain/entities/user_entity.dart';
import 'package:e_commerce/features/auth/domain/usecase/sign_in.dart';
import 'package:e_commerce/features/auth/domain/usecase/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn _signInUseCase;
  final SignOut _signOutUseCase;

  AuthBloc({required SignIn signInUseCase, required SignOut signOutUseCase})
    : _signInUseCase = signInUseCase,
      _signOutUseCase = signOutUseCase,
      super(AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _signInUseCase(event.email, event.password);

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Invalid credentials'));
      }
    } catch (e, stack) {
      // Có thêm stacktrace để debug dễ hơn
      emit(AuthError('Sign-in failed: ${e.toString()}'));
      addError(e, stack); // log error vào bloc observer
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
      emit(AuthUnauthenticated());
    } catch (e, stack) {
      emit(AuthError('Sign-out failed: ${e.toString()}'));
      addError(e, stack);
    }
  }
}
