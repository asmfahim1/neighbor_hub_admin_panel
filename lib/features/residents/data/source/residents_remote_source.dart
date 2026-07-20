import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_request_status.dart';
import '../../../../core/constants/apartment_status.dart';
import '../../../../core/constants/notification_category.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entity/residents_entity.dart';

/// The swappable "endpoint" boundary for the Residents feature. A future
/// custom backend adds `ResidentsApiSource implements ResidentsRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class ResidentsRemoteSource {
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId);
  Future<void> approveRequest({required ApartmentRequestEntity request, required String adminUid});
  Future<void> rejectRequest({required ApartmentRequestEntity request, required String adminUid});

  Stream<List<UserEntity>> watchResidentDirectory(String buildingId);
  Future<UserEntity?> fetchUser(String uid);

  /// All posts in the building — the caller filters client-side by `authorUid`.
  Future<List<PostEntity>> fetchPostsForActivitySummary(String buildingId);

  Future<void> removeResident({required String uid, required String apartmentId});

  Future<void> transferAdminRole({
    required String buildingId,
    required String currentAdminUid,
    required String successorUid,
  });
}

@LazySingleton(as: ResidentsRemoteSource)
class ResidentsFirestoreSource implements ResidentsRemoteSource {
  ResidentsFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.apartmentRequests, buildingId)
        .where(FirestoreFields.status, isEqualTo: ApartmentRequestStatus.pending.value);

    return _firestore.watchQuery(query).asyncMap((snapshot) async {
      final requests = snapshot.docs
          .map((doc) => ApartmentRequestEntity.fromJson(doc.data(), uid: doc.id))
          .toList();

      // Best-effort join: resolve each requester's displayName. A missing
      // user doc must never break the whole queue.
      return Future.wait(requests.map((request) async {
        try {
          final user = await fetchUser(request.uid);
          if (user == null) return request;
          return request.copyWith(requesterDisplayName: user.displayName);
        } catch (_) {
          return request;
        }
      }));
    });
  }

  @override
  Future<void> approveRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) async {
    final batch = _firestore.newBatch();
    batch.update(_firestore.document(FirestorePaths.apartmentRequest(request.uid)), {
      'status': ApartmentRequestStatus.approved.value,
      'decidedBy': adminUid,
      'decidedAt': _firestore.serverTimestamp,
    });
    batch.update(_firestore.document(FirestorePaths.apartment(request.apartmentId)), {
      'status': ApartmentStatus.occupied.value,
      'primaryResidentUid': request.uid,
      'updatedAt': _firestore.serverTimestamp,
    });
    batch.update(_firestore.document(FirestorePaths.user(request.uid)), {
      'buildingId': request.buildingId,
      'apartmentId': request.apartmentId,
    });
    await _firestore.commitBatch(batch);

    await _notifyDecision(
      request: request,
      title: 'Apartment request approved',
      body: 'Your request for apartment ${request.apartmentId} has been approved.',
    );
  }

  @override
  Future<void> rejectRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) async {
    await _firestore.updateDocument(FirestorePaths.apartmentRequest(request.uid), {
      'status': ApartmentRequestStatus.rejected.value,
      'decidedBy': adminUid,
      'decidedAt': _firestore.serverTimestamp,
    });

    await _notifyDecision(
      request: request,
      title: 'Apartment request declined',
      body: 'Your request for apartment ${request.apartmentId} was not approved.',
    );
  }

  /// Best-effort — a notification failure must never surface as an
  /// approve/reject failure (mirrors `AuthFirestoreSource.registerFcmTokenSilently`).
  Future<void> _notifyDecision({
    required ApartmentRequestEntity request,
    required String title,
    required String body,
  }) async {
    try {
      await _firestore.addDocument(FirestoreCollections.notifications, {
        'recipientUid': request.uid,
        'buildingId': request.buildingId,
        'category': NotificationCategory.announcement.value,
        'title': title,
        'body': body,
        'relatedPostId': null,
        'relatedConversationId': null,
        'isRead': false,
        'createdAt': _firestore.serverTimestamp,
      });
    } catch (e, stack) {
      AppLogger.error(
        'Apartment-request decision notification failed',
        tag: 'RESIDENTS',
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  Stream<List<UserEntity>> watchResidentDirectory(String buildingId) {
    final query = _firestore.buildingScoped(FirestoreCollections.users, buildingId);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserEntity.fromJson(doc.data(), uid: doc.id)).toList(),
        );
  }

  @override
  Future<UserEntity?> fetchUser(String uid) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.user(uid));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserEntity.fromJson(data, uid: uid);
  }

  @override
  Future<List<PostEntity>> fetchPostsForActivitySummary(String buildingId) async {
    final query = _firestore.buildingScoped(FirestoreCollections.posts, buildingId);
    final snapshot = await _firestore.getQuery(query);
    return snapshot.docs.map((doc) => PostEntity.fromJson(doc.data(), id: doc.id)).toList();
  }

  @override
  Future<void> removeResident({required String uid, required String apartmentId}) async {
    final batch = _firestore.newBatch();
    batch.update(_firestore.document(FirestorePaths.user(uid)), {'apartmentId': null});
    batch.update(_firestore.document(FirestorePaths.apartment(apartmentId)), {
      'status': ApartmentStatus.vacant.value,
      'primaryResidentUid': null,
      'updatedAt': _firestore.serverTimestamp,
    });
    batch.update(_firestore.document(FirestorePaths.userPrivateAccount(uid)), {
      'accountStatus': AccountStatus.removed.value,
    });
    await _firestore.commitBatch(batch);
  }

  @override
  Future<void> transferAdminRole({
    required String buildingId,
    required String currentAdminUid,
    required String successorUid,
  }) async {
    final batch = _firestore.newBatch();
    batch.update(_firestore.document(FirestorePaths.userPrivateAccount(successorUid)), {
      'role': UserRole.admin.value,
    });
    batch.update(_firestore.document(FirestorePaths.userPrivateAccount(currentAdminUid)), {
      'role': UserRole.resident.value,
    });
    batch.update(_firestore.document(FirestorePaths.building(buildingId)), {
      'adminUid': successorUid,
    });
    await _firestore.commitBatch(batch);
  }
}
