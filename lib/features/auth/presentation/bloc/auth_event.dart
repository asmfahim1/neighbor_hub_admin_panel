import 'package:equatable/equatable.dart';

import '../../domain/entity/auth_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once at bloc construction to start listening to
/// [WatchAuthStateUseCase]'s stream for the lifetime of the app.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Internal — emitted by the bloc's own stream subscription, never dispatched
/// from the UI.
class AuthSessionChanged extends AuthEvent {
  const AuthSessionChanged(this.session);
  final AuthSessionEntity? session;

  @override
  List<Object?> get props => [session];
}

class SignInWithEmailRequested extends AuthEvent {
  const SignInWithEmailRequested(this.email, this.password);
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignInWithAppleRequested extends AuthEvent {
  const SignInWithAppleRequested();
}

class PasswordResetRequested extends AuthEvent {
  const PasswordResetRequested(this.email);
  final String email;

  @override
  List<Object?> get props => [email];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}
