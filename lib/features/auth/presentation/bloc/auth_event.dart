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

/// Self-service admin sign-up ("Bootstrap-once" model, §7.1) — only ever
/// succeeds for the first caller; see `AuthRepository.signUpAsAdmin`.
class SignUpAsAdminRequested extends AuthEvent {
  const SignUpAsAdminRequested({
    required this.buildingName,
    required this.buildingAddress,
    required this.displayName,
    required this.email,
    required this.password,
  });

  final String buildingName;
  final String buildingAddress;
  final String displayName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [buildingName, buildingAddress, displayName, email, password];
}

/// Google variant of [SignUpAsAdminRequested] — see
/// `AuthRepository.signUpAsAdminWithGoogle`.
class SignUpWithGoogleRequested extends AuthEvent {
  const SignUpWithGoogleRequested({
    required this.buildingName,
    required this.buildingAddress,
  });

  final String buildingName;
  final String buildingAddress;

  @override
  List<Object?> get props => [buildingName, buildingAddress];
}

/// Apple variant of [SignUpAsAdminRequested] — see
/// `AuthRepository.signUpAsAdminWithApple`.
class SignUpWithAppleRequested extends AuthEvent {
  const SignUpWithAppleRequested({
    required this.buildingName,
    required this.buildingAddress,
  });

  final String buildingName;
  final String buildingAddress;

  @override
  List<Object?> get props => [buildingName, buildingAddress];
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
