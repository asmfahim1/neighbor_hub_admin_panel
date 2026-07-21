import 'package:injectable/injectable.dart';

import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/data_models.dart';
import '../../../../core/models/models.dart';

/// The swappable "endpoint" boundary for the Analytics feature. A future
/// custom backend adds `AnalyticsApiSource implements AnalyticsRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class AnalyticsRemoteSource {
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);
  Stream<List<PostEntity>> watchPosts(String buildingId, {int limit});
  Stream<List<PollEntity>> watchPolls(String buildingId);
}

@LazySingleton(as: AnalyticsRemoteSource)
class AnalyticsFirestoreSource implements AnalyticsRemoteSource {
  AnalyticsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) {
    final query = _firestore.buildingScoped(FirestoreCollections.apartments, buildingId);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => ApartmentModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<PostEntity>> watchPosts(String buildingId, {int limit = 500}) {
    // Matches the `(buildingId, createdAt desc)` composite index declared in
    // `05_FIRESTORE_DATABASE.md` §5. `limit` bounds the read at this feature's
    // documented single-building/~100-resident scale (§7.9) — a real
    // historical window would need a stored time-series, which the schema
    // deliberately doesn't have.
    final query = _firestore
        .buildingScoped(FirestoreCollections.posts, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .limit(limit);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromJson(doc.data(), id: doc.id)).toList(),
        );
  }

  @override
  Stream<List<PollEntity>> watchPolls(String buildingId) {
    final query = _firestore.buildingScoped(FirestoreCollections.polls, buildingId);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => PollModel.fromJson(doc.data(), id: doc.id)).toList(),
        );
  }
}
