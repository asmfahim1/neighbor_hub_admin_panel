import '../../../../core/constants/user_role.dart';

/// The resolved, signed-in admin session — composed from Firebase Auth
/// identity plus the Firestore role-gate check (`users/{uid}` +
/// `users/{uid}/private/account.role`), per
/// `admen_web_app_ui_functionality.md` §7.1.
///
/// This is feature-local (not a `core/models` entity) because it's a
/// composed view specific to the auth/session-gate use case, not a 1:1
/// mirror of a single Firestore document.
class AuthSessionEntity {
  const AuthSessionEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.buildingId,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final UserRole role;
  final String? buildingId;

  bool get isAdmin => role == UserRole.admin;
}
