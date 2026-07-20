import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entity/auth_entity.dart';
import '../../domain/usecase/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._watchAuthState,
    this._signInWithEmail,
    this._signInWithGoogle,
    this._signInWithApple,
    this._sendPasswordResetEmail,
    this._signOut,
  ) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSessionChanged>(_onSessionChanged);
    on<SignInWithEmailRequested>(_onSignInWithEmail);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithAppleRequested>(_onSignInWithApple);
    on<PasswordResetRequested>(_onPasswordReset);
    on<SignOutRequested>(_onSignOut);

    add(const AuthStarted());
  }

  final WatchAuthStateUseCase _watchAuthState;
  final SignInWithEmailUseCase _signInWithEmail;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignInWithAppleUseCase _signInWithApple;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmail;
  final SignOutUseCase _signOut;

  StreamSubscription<AuthSessionEntity?>? _authSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    await _authSubscription?.cancel();
    _authSubscription = _watchAuthState().listen((session) {
      add(AuthSessionChanged(session));
    });
  }

  void _onSessionChanged(AuthSessionChanged event, Emitter<AuthState> emit) {
    if (event.session == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearSession: true));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, session: event.session));
    }
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearMessage: true));
    final result = await _signInWithEmail(event.email, event.password);
    _emitSignInResult(result, emit);
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearMessage: true));
    final result = await _signInWithGoogle();
    _emitSignInResult(result, emit);
  }

  Future<void> _onSignInWithApple(
    SignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.authenticating, clearMessage: true));
    final result = await _signInWithApple();
    _emitSignInResult(result, emit);
  }

  void _emitSignInResult(Result<AuthSessionEntity> result, Emitter<AuthState> emit) {
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, message: failure.displayMessage)),
      (session) => emit(state.copyWith(status: AuthStatus.authenticated, session: session)),
    );
  }

  Future<void> _onPasswordReset(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(message: 'Password reset email sent.', clearMessage: false)),
    );
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    final result = await _signOut();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: AuthStatus.unauthenticated, clearSession: true)),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
