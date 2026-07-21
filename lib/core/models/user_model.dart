import 'user_entity.dart';
import '../constants/user_role.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `users/{uid}` (public profile). See
/// `lib/core/models/README.md` for why Model extends Entity.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.displayName,
    required super.authProvider,
    super.photoUrl,
    super.buildingId,
    super.apartmentId,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {required String uid}) {
    return UserModel(
      uid: uid,
      displayName: json['displayName']?.toString() ?? '',
      authProvider: AppAuthProvider.fromValue(json['authProvider']?.toString()),
      photoUrl: json['photoUrl']?.toString(),
      buildingId: json['buildingId']?.toString(),
      apartmentId: json['apartmentId']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      authProvider: entity.authProvider,
      photoUrl: entity.photoUrl,
      buildingId: entity.buildingId,
      apartmentId: entity.apartmentId,
      createdAt: entity.createdAt,
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
}

/// Data-layer DTO for `users/{uid}/private/account`.
class UserPrivateAccountModel extends UserPrivateAccountEntity {
  const UserPrivateAccountModel({
    required super.uid,
    required super.email,
    required super.role,
    required super.accountStatus,
    super.fcmToken,
    required super.createdAt,
  });

  factory UserPrivateAccountModel.fromJson(
    Map<String, dynamic> json, {
    required String uid,
  }) {
    return UserPrivateAccountModel(
      uid: uid,
      email: json['email']?.toString() ?? '',
      role: UserRole.fromValue(json['role']?.toString()),
      accountStatus: AccountStatus.fromValue(json['accountStatus']?.toString()),
      fcmToken: json['fcmToken']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory UserPrivateAccountModel.fromEntity(UserPrivateAccountEntity entity) {
    return UserPrivateAccountModel(
      uid: entity.uid,
      email: entity.email,
      role: entity.role,
      accountStatus: entity.accountStatus,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role.value,
        'accountStatus': accountStatus.value,
        'fcmToken': fcmToken,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
