import '../../../../core/utils/result.dart';
import '../entity/profile_entity.dart';

abstract class ProfileRepository {
  /// Realtime listener on the signed-in admin's own `users/{uid}` doc.
  Stream<UserEntity?> watchOwnProfile(String uid);

  /// Partial update — only `displayName`/`photoUrl` are ever written from
  /// this self-update path; `buildingId`/`apartmentId`/`authProvider`/
  /// `createdAt` are never touched here (those change only via the
  /// Residents approval/removal/transfer batches).
  Future<Result<void>> updateOwnProfile(
    String uid, {
    String? displayName,
    String? photoUrl,
  });

  Future<Result<void>> signOut();
}
