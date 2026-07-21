import '../../../../core/utils/result.dart';
import '../entity/auth_entity.dart';

abstract class AuthRepository {
  /// Emits the resolved admin session on every Firebase Auth state change,
  /// or `null` when signed out. A signed-in account whose role isn't
  /// `"admin"` is signed back out internally and this emits `null` — the
  /// Admin App has no state to represent "signed in but not an admin".
  Stream<AuthSessionEntity?> watchAuthState();

  Future<Result<AuthSessionEntity>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  Future<Result<AuthSessionEntity>> signInWithGoogle();

  Future<Result<AuthSessionEntity>> signInWithApple();

  /// Self-service admin sign-up ("Bootstrap-once" model, §7.1): creates a
  /// brand-new Firebase Auth account, then atomically creates the single
  /// building (with the new account as its admin), the account's public
  /// profile, and its private `role: "admin"` record. Only ever succeeds
  /// once globally — see `firestore.rules`'s `isBootstrappingFirstAdmin`
  /// and siblings. If the Firestore bootstrap fails after the auth account
  /// was created (e.g. lost the race to another concurrent sign-up), the
  /// just-created auth account is deleted so the email isn't left stuck.
  Future<Result<AuthSessionEntity>> signUpAsAdmin({
    required String buildingName,
    required String buildingAddress,
    required String displayName,
    required String email,
    required String password,
  });

  /// Google variant of [signUpAsAdmin] — signs in with Google first, then
  /// bootstraps the same way. If the Google account is already registered
  /// (has an existing `users/{uid}` profile), returns a
  /// [ValidationFailure] telling the user to sign in instead, since this is
  /// an *existing* account, not a fresh one — no auth account is deleted.
  Future<Result<AuthSessionEntity>> signUpAsAdminWithGoogle({
    required String buildingName,
    required String buildingAddress,
  });

  /// Apple equivalent of [signUpAsAdminWithGoogle].
  Future<Result<AuthSessionEntity>> signUpAsAdminWithApple({
    required String buildingName,
    required String buildingAddress,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
