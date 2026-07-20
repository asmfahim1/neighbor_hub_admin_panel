import 'package:injectable/injectable.dart';

import '../../../../core/firebase/firebase_auth_service.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/utils/logger.dart';

/// The swappable "endpoint" boundary for the Auth feature.
///
/// [AuthFirestoreSource] is today's implementation, built on
/// [FirebaseAuthService] (identity) + [FirestoreService] (role lookup). A
/// future custom backend would add e.g. `AuthApiSource implements
/// AuthRemoteSource` using `ApiService`/`DioClient` and flip the DI binding
/// — nothing in `domain/` or `data/repository` would change.
abstract class AuthRemoteSource {
  Stream<String?> get authUidChanges;
  String? get currentUid;

  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> signInWithGoogle();
  Future<String> signInWithApple();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();

  /// `users/{uid}` public profile — null if it doesn't exist.
  Future<UserEntity?> fetchUserProfile(String uid);

  /// `users/{uid}/private/account` — null if it doesn't exist.
  Future<UserPrivateAccountEntity?> fetchPrivateAccount(String uid);

  /// Best-effort: persists the current device's FCM token to
  /// `users/{uid}/private/account.fcmToken` (`05_FIRESTORE_DATABASE.md` §3.2b).
  /// Never throws — a failure here must not block sign-in.
  Future<void> registerFcmTokenSilently(String uid);
}

@LazySingleton(as: AuthRemoteSource)
class AuthFirestoreSource implements AuthRemoteSource {
  AuthFirestoreSource(this._auth, this._firestore, this._push);

  final FirebaseAuthService _auth;
  final FirestoreService _firestore;
  final PushNotificationService _push;

  @override
  Stream<String?> get authUidChanges =>
      _auth.authStateChanges.map((user) => user?.uid);

  @override
  String? get currentUid => _auth.currentUid;

  @override
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email, password);
    return result.fold((failure) => throw failure, (user) => user.uid);
  }

  @override
  Future<String> signInWithGoogle() async {
    final result = await _auth.signInWithGoogle();
    return result.fold((failure) => throw failure, (user) => user.uid);
  }

  @override
  Future<String> signInWithApple() async {
    final result = await _auth.signInWithApple();
    return result.fold((failure) => throw failure, (user) => user.uid);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _auth.sendPasswordResetEmail(email);
    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<void> signOut() async {
    final result = await _auth.signOut();
    result.fold((failure) => throw failure, (_) {});
  }

  @override
  Future<UserEntity?> fetchUserProfile(String uid) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.user(uid));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserEntity.fromJson(data, uid: uid);
  }

  @override
  Future<UserPrivateAccountEntity?> fetchPrivateAccount(String uid) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.userPrivateAccount(uid));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserPrivateAccountEntity.fromJson(data, uid: uid);
  }

  @override
  Future<void> registerFcmTokenSilently(String uid) async {
    try {
      final granted = await _push.requestPermission();
      if (!granted) return;
      final token = await _push.getToken();
      if (token == null || token.isEmpty) return;
      await _firestore.updateDocument(
        FirestorePaths.userPrivateAccount(uid),
        {'fcmToken': token},
      );
    } catch (e, stack) {
      // Best-effort only — push registration must never block sign-in.
      AppLogger.error('FCM token registration failed', tag: 'AUTH', error: e, stackTrace: stack);
    }
  }
}
