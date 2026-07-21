import 'package:equatable/equatable.dart';

import '../constants/user_role.dart';

/// Mirrors `users/{uid}` (public profile) — `05_FIRESTORE_DATABASE.md` §3.2.
///
/// Deliberately holds only what any same-building member may read (Resident
/// Directory, post/comment authorship, chat participant info). Sensitive
/// fields live in [UserPrivateAccountEntity].
///
/// Pure domain object — no Firestore/JSON knowledge. See [UserModel]
/// (`user_model.dart`) for parsing/serialization.
class UserEntity extends Equatable {
  const UserEntity({
    required this.uid,
    required this.displayName,
    required this.authProvider,
    this.photoUrl,
    this.buildingId,
    this.apartmentId,
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final AppAuthProvider authProvider;

  /// Only populated when [authProvider] is [AppAuthProvider.google].
  final String? photoUrl;

  /// Null while unassigned; set on apartment approval.
  final String? buildingId;

  /// Non-null iff this user is the Primary Resident of an apartment.
  final String? apartmentId;

  final DateTime createdAt;

  bool get isPrimaryResident => apartmentId != null;

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    String? buildingId,
    String? apartmentId,
  }) {
    return UserEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      authProvider: authProvider,
      photoUrl: photoUrl ?? this.photoUrl,
      buildingId: buildingId ?? this.buildingId,
      apartmentId: apartmentId ?? this.apartmentId,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [uid, displayName, authProvider, photoUrl, buildingId, apartmentId, createdAt];
}

/// Mirrors `users/{uid}/private/account` — `05_FIRESTORE_DATABASE.md` §3.2b.
///
/// Never readable by other residents; only the owner and building admins.
/// Pure domain object — see [UserPrivateAccountModel] for parsing/serialization.
class UserPrivateAccountEntity extends Equatable {
  const UserPrivateAccountEntity({
    required this.uid,
    required this.email,
    required this.role,
    required this.accountStatus,
    this.fcmToken,
    required this.createdAt,
  });

  final String uid;
  final String email;
  final UserRole role;
  final AccountStatus accountStatus;
  final String? fcmToken;
  final DateTime createdAt;

  @override
  List<Object?> get props => [uid, email, role, accountStatus, fcmToken, createdAt];
}
