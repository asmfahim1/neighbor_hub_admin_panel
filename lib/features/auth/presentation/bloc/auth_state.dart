import 'package:equatable/equatable.dart';

import '../../domain/entity/auth_entity.dart';

/// - [unknown]: initial, still resolving the Firebase Auth session gate.
/// - [authenticating]: a sign-in/reset/sign-out action is in flight.
/// - [authenticated]: a valid admin [AuthState.session] is present.
/// - [unauthenticated]: signed out (or never signed in).
/// - [failure]: the last action failed; [message] has human-readable copy.
///   A sign-in that succeeds at the Firebase Auth layer but fails the
///   `role == "admin"` gate (§7.1) lands here with that message, and the
///   repository has already signed the account back out — a follow-up
///   [AuthSessionChanged] (`null`) moves the state to [unauthenticated]
///   right after.
enum AuthStatus { unknown, authenticating, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.message,
  });

  final AuthStatus status;
  final AuthSessionEntity? session;
  final String? message;

  bool get isAdmin => status == AuthStatus.authenticated && session?.isAdmin == true;

  AuthState copyWith({
    AuthStatus? status,
    AuthSessionEntity? session,
    bool clearSession = false,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
