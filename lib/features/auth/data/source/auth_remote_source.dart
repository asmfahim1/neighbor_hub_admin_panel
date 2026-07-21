import 'package:injectable/injectable.dart';

import '../../../../core/constants/user_role.dart';
import '../../../../core/firebase/firebase_auth_service.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/building_model.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/utils/logger.dart';

/// Identity fields surfaced by a Google/Apple sign-in, for use by the
/// bootstrap-admin sign-up flow (`AuthRepositoryImpl.signUpAsAdminWithGoogle`/
/// `signUpAsAdminWithApple`). `email`/`displayName` may be null — Apple in
/// particular only returns a name on the account's very first authorization.
typedef AuthProviderIdentity = ({String uid, String? email, String? displayName});

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

  /// Creates a brand-new email/password Firebase Auth account (signed in
  /// immediately) — the first step of the self-service admin sign-up flow
  /// (§7.1, "Bootstrap-once" model). Returns the new uid.
  Future<String> createAccountWithEmailAndPassword(String email, String password);

  /// Google sign-in used as the first step of the admin sign-up flow.
  /// Unlike [signInWithGoogle], this also surfaces the provider's `email`/
  /// `displayName` so [bootstrapAdminAccount] can use them — Firebase Auth
  /// happily signs in an *existing* Google identity too, so the caller must
  /// check [fetchUserProfile] before bootstrapping to detect "already
  /// registered" instead of assuming this is always a new account.
  Future<AuthProviderIdentity> signInWithGoogleForBootstrap();

  /// Apple equivalent of [signInWithGoogleForBootstrap].
  Future<AuthProviderIdentity> signInWithAppleForBootstrap();

  /// Creates `buildings/{singleBuildingId}` (with [uid] as `adminUid`),
  /// `users/{uid}` (with `buildingId` already set, `apartmentId: null`), and
  /// `users/{uid}/private/account` (`role: "admin"`) in one `WriteBatch`.
  /// Only ever succeeds once globally — gated by the
  /// `isBootstrappingFirstAdmin`/`isBootstrappingAdminUserCreate`/
  /// `isBootstrappingAdminPrivateCreate` rules in `firestore.rules`.
  Future<void> bootstrapAdminAccount({
    required String uid,
    required String email,
    required String displayName,
    required String buildingName,
    required String buildingAddress,
    required AppAuthProvider authProvider,
  });

  /// Compensating action: deletes the just-created Firebase Auth account if
  /// [bootstrapAdminAccount] fails (e.g. lost the race to claim the single
  /// building), so the email address isn't left stuck on an orphaned
  /// auth-only account with no matching Firestore profile.
  Future<void> deleteCurrentAccount();

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
    return UserModel.fromJson(data, uid: uid);
  }

  @override
  Future<UserPrivateAccountEntity?> fetchPrivateAccount(String uid) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.userPrivateAccount(uid));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserPrivateAccountModel.fromJson(data, uid: uid);
  }

  @override
  Future<String> createAccountWithEmailAndPassword(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email, password);
    return result.fold((failure) => throw failure, (user) => user.uid);
  }

  @override
  Future<AuthProviderIdentity> signInWithGoogleForBootstrap() async {
    final result = await _auth.signInWithGoogle();
    return result.fold(
      (failure) => throw failure,
      (user) => (uid: user.uid, email: user.email, displayName: user.displayName),
    );
  }

  @override
  Future<AuthProviderIdentity> signInWithAppleForBootstrap() async {
    final result = await _auth.signInWithApple();
    return result.fold(
      (failure) => throw failure,
      (user) => (uid: user.uid, email: user.email, displayName: user.displayName),
    );
  }

  @override
  Future<void> bootstrapAdminAccount({
    required String uid,
    required String email,
    required String displayName,
    required String buildingName,
    required String buildingAddress,
    required AppAuthProvider authProvider,
  }) async {
    final now = DateTime.now();
    final batch = _firestore.newBatch();

    batch.set(
      _firestore.document(FirestorePaths.building(FirestorePaths.singleBuildingId)),
      BuildingModel(
        id: FirestorePaths.singleBuildingId,
        name: buildingName,
        address: buildingAddress,
        totalFloors: 0,
        apartmentsPerFloor: 0,
        adminUid: uid,
        createdAt: now,
      ).toJson(),
    );

    batch.set(
      _firestore.document(FirestorePaths.user(uid)),
      UserModel(
        uid: uid,
        displayName: displayName,
        authProvider: authProvider,
        buildingId: FirestorePaths.singleBuildingId,
        createdAt: now,
      ).toJson(),
    );

    batch.set(
      _firestore.document(FirestorePaths.userPrivateAccount(uid)),
      UserPrivateAccountModel(
        uid: uid,
        email: email,
        role: UserRole.admin,
        accountStatus: AccountStatus.active,
        createdAt: now,
      ).toJson(),
    );

    await _firestore.commitBatch(batch);
  }

  @override
  Future<void> deleteCurrentAccount() async {
    final result = await _auth.deleteCurrentUser();
    result.fold((failure) => throw failure, (_) {});
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
