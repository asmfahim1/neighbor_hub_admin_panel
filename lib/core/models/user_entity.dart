import 'package:equatable/equatable.dart';

import '../constants/user_role.dart';
import '../firebase/firestore_converters.dart';

/// Mirrors `users/{uid}` (public profile) — `05_FIRESTORE_DATABASE.md` §3.2.
///
/// Deliberately holds only what any same-building member may read (Resident
/// Directory, post/comment authorship, chat participant info). Sensitive
/// fields live in [UserPrivateAccountEntity].
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

  factory UserEntity.fromJson(Map<String, dynamic> json, {required String uid}) {
    return UserEntity(
      uid: uid,
      displayName: json['displayName']?.toString() ?? '',
      authProvider: AppAuthProvider.fromValue(json['authProvider']?.toString()),
      photoUrl: json['photoUrl']?.toString(),
      buildingId: json['buildingId']?.toString(),
      apartmentId: json['apartmentId']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'authProvider': authProvider.value,
        'photoUrl': photoUrl,
        'buildingId': buildingId,
        'apartmentId': apartmentId,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

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

  factory UserPrivateAccountEntity.fromJson(
    Map<String, dynamic> json, {
    required String uid,
  }) {
    return UserPrivateAccountEntity(
      uid: uid,
      email: json['email']?.toString() ?? '',
      role: UserRole.fromValue(json['role']?.toString()),
      accountStatus: AccountStatus.fromValue(json['accountStatus']?.toString()),
      fcmToken: json['fcmToken']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role.value,
        'accountStatus': accountStatus.value,
        'fcmToken': fcmToken,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [uid, email, role, accountStatus, fcmToken, createdAt];
}
