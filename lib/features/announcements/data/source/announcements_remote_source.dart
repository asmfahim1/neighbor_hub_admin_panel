import 'package:injectable/injectable.dart';

import '../../../../core/constants/notification_category.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../domain/entity/announcements_entity.dart';

/// The swappable "endpoint" boundary for the Announcements feature. A future
/// custom backend adds `AnnouncementsApiSource implements
/// AnnouncementsRemoteSource` and flips the DI binding — nothing in
/// `domain/` or `data/repository` changes.
abstract class AnnouncementsRemoteSource {
  Stream<List<AnnouncementEntity>> watchAnnouncements(String buildingId);

  /// Creates the announcement doc and fans out one `notifications` doc per
  /// resident in the building, in a single call.
  Future<void> createAnnouncement({
    required String buildingId,
    required String title,
    required String body,
    required String createdBy,
  });

  Future<void> updateAnnouncement(AnnouncementEntity announcement);
  Future<void> deleteAnnouncement(String announcementId);
}

@LazySingleton(as: AnnouncementsRemoteSource)
class AnnouncementsFirestoreSource implements AnnouncementsRemoteSource {
  AnnouncementsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<AnnouncementEntity>> watchAnnouncements(String buildingId) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.announcements, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => AnnouncementEntity.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<void> createAnnouncement({
    required String buildingId,
    required String title,
    required String body,
    required String createdBy,
  }) async {
    // 1. Create the announcement doc first so we have its id for
    //    `relatedPostId`-style traceability if ever needed, and so a
    //    resident-fan-out failure never blocks the announcement itself from
    //    existing (the fan-out is a best-effort broadcast, not part of the
    //    announcement's own atomicity contract).
    await _firestore.addDocument(FirestoreCollections.announcements, {
      'buildingId': buildingId,
      'title': title,
      'body': body,
      'createdBy': createdBy,
      'createdAt': _firestore.serverTimestamp,
    });

    // 2. Fan out one `notifications` doc per resident in the building,
    //    chunked at the WriteBatch cap (§7.7). Mirrors
    //    `BuildingsFirestoreSource.generateApartments`'s chunking pattern.
    final residentsSnapshot = await _firestore.getQuery(
      _firestore.buildingScoped(FirestoreCollections.users, buildingId),
    );
    final residentUids = residentsSnapshot.docs.map((doc) => doc.id).toList();

    if (residentUids.isEmpty) return;

    await _firestore.writeInChunks<String>(residentUids, (batch, recipientUid) {
      final ref = _firestore.collection(FirestoreCollections.notifications).doc();
      batch.set(ref, {
        'recipientUid': recipientUid,
        'buildingId': buildingId,
        'category': NotificationCategory.announcement.value,
        'title': title,
        'body': body,
        'relatedPostId': null,
        'relatedConversationId': null,
        'isRead': false,
        'createdAt': _firestore.serverTimestamp,
      });
    });
  }

  @override
  Future<void> updateAnnouncement(AnnouncementEntity announcement) async {
    await _firestore.updateDocument(
      FirestorePaths.announcement(announcement.id),
      {'title': announcement.title, 'body': announcement.body},
    );
  }

  @override
  Future<void> deleteAnnouncement(String announcementId) async {
    await _firestore.deleteDocument(FirestorePaths.announcement(announcementId));
  }
}
