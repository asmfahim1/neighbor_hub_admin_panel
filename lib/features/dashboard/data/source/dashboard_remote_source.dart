import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_request_status.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/models.dart';

/// The swappable "endpoint" boundary for the Dashboard feature. A future
/// custom backend adds `DashboardApiSource implements DashboardRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class DashboardRemoteSource {
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId);
  Stream<List<PostEntity>> watchRecentPosts(String buildingId, {int limit});
  Stream<List<AnnouncementEntity>> watchRecentAnnouncements(String buildingId, {int limit});
}

@LazySingleton(as: DashboardRemoteSource)
class DashboardFirestoreSource implements DashboardRemoteSource {
  DashboardFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) {
    final query = _firestore.buildingScoped(FirestoreCollections.apartments, buildingId);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => ApartmentEntity.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.apartmentRequests, buildingId)
        .where(FirestoreFields.status, isEqualTo: ApartmentRequestStatus.pending.value);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => ApartmentRequestEntity.fromJson(doc.data(), uid: doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<PostEntity>> watchRecentPosts(String buildingId, {int limit = 50}) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.posts, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(limit);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostEntity.fromJson(doc.data(), id: doc.id)).toList(),
        );
  }

  @override
  Stream<List<AnnouncementEntity>> watchRecentAnnouncements(String buildingId, {int limit = 20}) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.announcements, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(limit);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => AnnouncementEntity.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }
}
