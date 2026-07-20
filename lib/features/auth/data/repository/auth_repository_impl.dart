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
