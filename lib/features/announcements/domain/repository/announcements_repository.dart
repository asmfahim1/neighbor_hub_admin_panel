import '../../../../core/utils/result.dart';
import '../entity/announcements_entity.dart';

abstract class AnnouncementsRepository {
  /// Realtime listener on `announcements where buildingId == X`, ordered
  /// `createdAt desc`.
  Stream<List<AnnouncementEntity>> watchAnnouncements(String buildingId);

  /// Creates `announcements/{id}` and, in the same operation, fans out one
  /// `notifications` doc per resident in the building (§7.7). `createdBy` is
  /// the admin's uid, supplied by the caller (e.g. from `CurrentSession`) —
  /// this repository never reaches into session state itself.
  Future<Result<void>> createAnnouncement({
    required String buildingId,
    required String title,
    required String body,
    required String createdBy,
  });

  Future<Result<void>> updateAnnouncement(AnnouncementEntity announcement);

  Future<Result<void>> deleteAnnouncement(String announcementId);
}
