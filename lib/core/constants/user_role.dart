/// Mirrors `users/{uid}/private/account.role` in `05_FIRESTORE_DATABASE.md` §3.2b.
///
/// `superadmin` is reserved and unused in MVP (single-admin-per-building model).
enum UserRole {
  resident,
  admin,
  superadmin;

  String get value => switch (this) {
        UserRole.resident => 'resident',
        UserRole.admin => 'admin',
        UserRole.superadmin => 'superadmin',
      };

  static UserRole fromValue(String? value) => switch (value) {
        'admin' => UserRole.admin,
        'superadmin' => UserRole.superadmin,
        _ => UserRole.resident,
      };
}

/// Mirrors `users/{uid}/private/account.accountStatus` in `05_FIRESTORE_DATABASE.md` §3.2b.
enum AccountStatus {
  active,
  deletionRequested,
  removed;

  String get value => switch (this) {
        AccountStatus.active => 'active',
        AccountStatus.deletionRequested => 'deletion_requested',
        AccountStatus.removed => 'removed',
      };

  static AccountStatus fromValue(String? value) => switch (value) {
        'deletion_requested' => AccountStatus.deletionRequested,
        'removed' => AccountStatus.removed,
        _ => AccountStatus.active,
      };
}

/// Mirrors `users/{uid}.authProvider` in `05_FIRESTORE_DATABASE.md` §3.2.
enum AppAuthProvider {
  password,
  google,
  apple;

  String get value => switch (this) {
        AppAuthProvider.password => 'password',
        AppAuthProvider.google => 'google',
        AppAuthProvider.apple => 'apple',
      };

  static AppAuthProvider fromValue(String? value) => switch (value) {
        'google' => AppAuthProvider.google,
        'apple' => AppAuthProvider.apple,
        _ => AppAuthProvider.password,
      };
}
