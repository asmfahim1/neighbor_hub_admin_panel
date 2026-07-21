import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/notification_entity.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/notifications/notification_service.dart';

/// The swappable "endpoint" boundary for the Notifications feature. A future
/// custom backend adds `NotificationsApiSource implements
/// NotificationsRemoteSource` and flips the DI binding — nothing in
/// `domain/` or `data/repository` changes.
abstract class NotificationsRemoteSource {
  Stream<List<NotificationEntity>> watchInbox(String recipientUid);
  Future<void> markAsRead(String notificationId);
}

@LazySingleton(as: NotificationsRemoteSource)
class NotificationsFirestoreSource implements NotificationsRemoteSource {
  NotificationsFirestoreSource(this._firestore, this._localNotifications);

  final FirestoreService _firestore;
  final NotificationService _localNotifications;

  @override
  Stream<List<NotificationEntity>> watchInbox(String recipientUid) {
    final query = _firestore
        .collection(FirestoreCollections.notifications)
        .where('recipientUid', isEqualTo: recipientUid)
        .orderBy(FirestoreFields.createdAt, descending: true);

    // Closure-local: true only for the very first snapshot of *this*
    // subscription, so pre-existing notifications never trigger a local
    // notification on app start — only genuinely new docs added afterward
    // while the listener is alive (§7.11).
    var isFirstSnapshot = true;

    return _firestore.watchQuery(query).map((snapshot) {
      if (!isFirstSnapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added) continue;
          final data = change.doc.data();
          if (data == null) continue;
          final notification = NotificationModel.fromJson(data, id: change.doc.id);
          _localNotifications.show(title: notification.title, body: notification.body);
        }
      }
      isFirstSnapshot = false;

      return snapshot.docs
          .map((doc) => NotificationModel.fromJson(doc.data(), id: doc.id))
          .toList();
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.updateDocument(
      FirestorePaths.notification(notificationId),
      {'isRead': true},
    );
  }
}
