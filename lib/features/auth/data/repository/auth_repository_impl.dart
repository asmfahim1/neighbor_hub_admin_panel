import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/firebase/current_session.dart';
import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/auth_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../source/auth_remote_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._session);

  final AuthRemoteSource _remote;
  final CurrentSession _session;

  static const _blockedMessage = 'This app is for building administrators.';

  @override
  Stream<AuthSessionEntity?> watchAuthState() {
    return _remote.authUidChanges.asyncMap((uid) async {
      if (uid == null) {
        _session.clear();
        return null;
      }
      return _resolveSession(uid, signOutIfBlocked: true);
    });
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _guardSignIn(() => _remote.signInWithEmailAndPassword(email, password));
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithGoogle() async {
    return _guardSignIn(_remote.signInWithGoogle);
  }

  @override
  Future<Result<AuthSessionEntity>> signInWithApple() async {
    return _guardSignIn(_remote.signInWithApple);
  }

  @override
  Future<Result<AuthSessionEntity>> signUpAsAdmin({
    required String buildingName,
    required String buildingAddress,
    required String displayName,
    required String email,
    required String password,
  }) async {
    String? uid;
    try {
      uid = await _remote.createAccountWithEmailAndPassword(email, password);
      await _remote.bootstrapAdminAccount(
        uid: uid,
        email: email,
        displayName: displayName,
        buildingName: buildingName,
        buildingAddress: buildingAddress,
        authProvider: AppAuthProvider.password,
      );
      final session = await _resolveSession(uid, signOutIfBlocked: true);
      if (session == null) {
        return const Left(UnknownFailure('Account created but sign-in failed. Please try signing in.'));
      }
      unawaited(_remote.registerFcmTokenSilently(uid));
      return Right(session);
    } catch (e, stack) {
      if (uid != null) {
        // Compensating cleanup: the auth account exists but the Firestore
        // bootstrap didn't complete (most likely someone else won the race
        // to claim the single building) — delete it so this email can be
        // used to try again instead of being permanently stuck.
        try {
          await _remote.deleteCurrentAccount();
        } catch (_) {
          // Best-effort only; surfacing the original failure matters more.
        }
      }
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> signUpAsAdminWithGoogle({
    required String buildingName,
    required String buildingAddress,
  }) {
    return _signUpWithProvider(
      signIn: _remote.signInWithGoogleForBootstrap,
      authProvider: AppAuthProvider.google,
      buildingName: buildingName,
      buildingAddress: buildingAddress,
    );
  }

  @override
  Future<Result<AuthSessionEntity>> signUpAsAdminWithApple({
    required String buildingName,
    required String buildingAddress,
  }) {
    return _signUpWithProvider(
      signIn: _remote.signInWithAppleForBootstrap,
      authProvider: AppAuthProvider.apple,
      buildingName: buildingName,
      buildingAddress: buildingAddress,
    );
  }

  /// Shared Google/Apple admin sign-up path. Unlike [signUpAsAdmin] (a
  /// brand-new email/password account every time), Firebase happily signs
  /// in an *existing* Google/Apple identity — so an existing `users/{uid}`
  /// profile means this person should sign in instead, not bootstrap again.
  /// No compensating delete on failure: since the identity is persistent
  /// (same uid every attempt), a lost bootstrap race just means the next
  /// attempt naturally retries against the same uid, with no orphaned
  /// email/account left behind the way a fresh email/password account
  /// would leave one.
  Future<Result<AuthSessionEntity>> _signUpWithProvider({
    required Future<AuthProviderIdentity> Function() signIn,
    required AppAuthProvider authProvider,
    required String buildingName,
    required String buildingAddress,
  }) async {
    try {
      final identity = await signIn();
      final existingProfile = await _remote.fetchUserProfile(identity.uid);
      if (existingProfile != null) {
        return const Left(
          ValidationFailure('This account is already registered. Please sign in instead.'),
        );
      }

      await _remote.bootstrapAdminAccount(
        uid: identity.uid,
        email: identity.email ?? '',
        displayName: identity.displayName ?? '',
        buildingName: buildingName,
        buildingAddress: buildingAddress,
        authProvider: authProvider,
      );
      final session = await _resolveSession(identity.uid, signOutIfBlocked: true);
      if (session == null) {
        return const Left(UnknownFailure('Account created but sign-in failed. Please try signing in.'));
      }
      unawaited(_remote.registerFcmTokenSilently(identity.uid));
      return Right(session);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remote.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
      _session.clear();
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  Future<Result<AuthSessionEntity>> _guardSignIn(
    Future<String> Function() signIn,
  ) async {
    try {
      final uid = await signIn();
      final session = await _resolveSession(uid, signOutIfBlocked: true);
      if (session == null) {
        return const Left(UnauthorizedFailure(_blockedMessage));
      }
      unawaited(_remote.registerFcmTokenSilently(uid));
      return Right(session);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  /// Reads `users/{uid}` + `users/{uid}/private/account`, and enforces the
  /// role gate (§7.1): a non-admin (or missing-profile) account is signed
  /// back out and `null` is returned instead of a session.
  Future<AuthSessionEntity?> _resolveSession(
    String uid, {
    required bool signOutIfBlocked,
  }) async {
    final profile = await _remote.fetchUserProfile(uid);
    final account = await _remote.fetchPrivateAccount(uid);

    if (profile == null || account == null || account.role != UserRole.admin) {
      if (signOutIfBlocked) {
        await _remote.signOut();
      }
      _session.clear();
      return null;
    }

    _session.update(uid: uid, buildingId: profile.buildingId, role: account.role);

    return AuthSessionEntity(
      uid: uid,
      email: account.email,
      displayName: profile.displayName,
      role: account.role,
      buildingId: profile.buildingId,
    );
  }
}
