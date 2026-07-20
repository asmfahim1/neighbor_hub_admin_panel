import '../../../../core/utils/result.dart';
import '../entity/notifications_entity.dart';

abstract class NotificationsRepository {
  /// Realtime listener on `notifications where recipientUid == myUid`,
  /// ordered `createdAt desc` (§7.11). Category filtering is done
  /// client-side over this list (see the bloc), not as a second Firestore
  /// `where` — no composite index for `(recipientUid, category, createdAt)`
  /// is declared in `05_FIRESTORE_DATABASE.md` §5.
  Stream<List<NotificationEntity>> watchInbox(String recipientUid);

  Future<Result<void>> markAsRead(String notificationId);
}
