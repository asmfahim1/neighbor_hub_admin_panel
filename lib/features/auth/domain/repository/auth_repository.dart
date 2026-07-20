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

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();
}
