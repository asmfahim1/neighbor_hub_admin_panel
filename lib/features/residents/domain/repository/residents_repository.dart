import '../../../../core/utils/result.dart';
import '../entity/residents_entity.dart';

abstract class ResidentsRepository {
  // --- 7.5.1 Pending Request Queue ---

  /// Realtime listener on `apartment_requests where buildingId==X && status=="pending"`,
  /// with each requester's `displayName` best-effort resolved from `users/{uid}`.
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId);

  /// One `WriteBatch`: approves the request, occupies the apartment, and
  /// binds the resident's `users/{uid}` doc. `adminUid` is the caller's own
  /// uid (`decidedBy`) — supplied by the presentation layer, not read from
  /// session state inside this repository.
  Future<Result<void>> approveRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  });

  /// Rejects the request — the apartment is never touched.
  Future<Result<void>> rejectRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  });

  // --- 7.5.2 Resident Directory ---

  /// Realtime listener on `users where buildingId==X`.
  Stream<List<UserEntity>> watchResidentDirectory(String buildingId);

  // --- 7.5.3 Resident Detail & Removal ---

  Future<Result<UserEntity?>> getResident(String uid);

  /// Lightweight post/comment/reaction activity summary for one resident,
  /// computed client-side over the building's `posts` (see architecture
  /// notes in `residents_plan.md` for why this isn't a filtered query).
  Future<Result<ResidentActivitySummaryEntity>> getResidentActivitySummary({
    required String buildingId,
    required String uid,
  });

  /// One `WriteBatch`: unbinds the resident, vacates the apartment, and
  /// marks the account removed.
  Future<Result<void>> removeResident({
    required String uid,
    required String apartmentId,
  });

  // --- 7.5.4 Transfer Admin Role ---

  /// One `WriteBatch`: promotes [successorUid] to admin, demotes
  /// [currentAdminUid] to resident, and repoints `buildings/{buildingId}.adminUid`.
  Future<Result<void>> transferAdminRole({
    required String buildingId,
    required String currentAdminUid,
    required String successorUid,
  });
}
