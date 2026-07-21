import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../response_handler/api_failure.dart';
import '../utils/result.dart';

/// Wraps [FirebaseAuth] + the Google/Apple sign-in SDKs behind one typed,
/// `Result`-returning surface.
///
/// This is the *only* file in the app that imports `firebase_auth`,
/// `google_sign_in`, or `sign_in_with_apple` directly — every feature talks
/// to authentication through this service, never the SDKs themselves.
/// Reusable as-is in the future Resident App.
///
/// Session persistence is Firebase Auth's own (per
/// `admen_web_app_ui_functionality.md` §7.1) — there is deliberately no
/// custom token storage here; `SessionManager`/`DioClient` remain reserved
/// for a future REST backend.
@lazySingleton
class FirebaseAuthService {
  FirebaseAuthService(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String? get currentUid => _auth.currentUser?.uid;

  Future<Result<User>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(UnauthorizedFailure('Sign-in failed. Please try again.'));
      }
      return Right(user);
    } on FirebaseAuthException catch (e, stack) {
      return Left(AppFailure.fromFirebaseAuthException(e, stack));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  Future<Result<User>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(UnknownFailure('Sign-in was cancelled.'));
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return const Left(UnauthorizedFailure('Google sign-in failed. Please try again.'));
      }
      return Right(user);
    } on FirebaseAuthException catch (e, stack) {
      return Left(AppFailure.fromFirebaseAuthException(e, stack));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  Future<Result<User>> signInWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final user = userCredential.user;
      if (user == null) {
        return const Left(UnauthorizedFailure('Apple sign-in failed. Please try again.'));
      }

      // Apple only returns the display name on the very first authorization.
      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((e) => e != null && e.isNotEmpty).join(' ');
      if (fullName.isNotEmpty && (user.displayName == null || user.displayName!.isEmpty)) {
        await user.updateDisplayName(fullName);
      }

      return Right(user);
    } on SignInWithAppleAuthorizationException catch (e, stack) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(UnknownFailure('Sign-in was cancelled.'));
      }
      return Left(AppFailure.fromException(e, stack));
    } on FirebaseAuthException catch (e, stack) {
      return Left(AppFailure.fromFirebaseAuthException(e, stack));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  /// Creates a brand-new email/password account and signs it in
  /// immediately (Firebase Auth's own behavior). Used by the self-service
  /// admin sign-up flow — see `AuthRepositoryImpl.signUpAsAdmin`.
  Future<Result<User>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(UnknownFailure('Account creation failed. Please try again.'));
      }
      return Right(user);
    } on FirebaseAuthException catch (e, stack) {
      return Left(AppFailure.fromFirebaseAuthException(e, stack));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  /// Deletes the currently signed-in Firebase Auth user — a compensating
  /// action for when Firestore writes fail right after account creation
  /// (e.g. a bootstrap-admin sign-up race), so the email address isn't left
  /// permanently stuck on an orphaned auth-only account.
  Future<Result<void>> deleteCurrentUser() async {
    try {
      await _auth.currentUser?.delete();
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (e, stack) {
      return Left(AppFailure.fromFirebaseAuthException(e, stack));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  /// Cryptographically secure random string used as the Apple sign-in nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();
}
