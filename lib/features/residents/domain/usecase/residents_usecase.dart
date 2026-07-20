import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/residents_entity.dart';
import '../repository/residents_repository.dart';

@injectable
class WatchPendingRequestsUseCase {
  WatchPendingRequestsUseCase(this._repo);
  final ResidentsRepository _repo;

  Stream<List<ApartmentRequestEntity>> call(String buildingId) =>
      _repo.watchPendingRequests(buildingId);
}

@injectable
class ApproveRequestUseCase {
  ApproveRequestUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<void>> call({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) =>
      _repo.approveRequest(request: request, adminUid: adminUid);
}

@injectable
class RejectRequestUseCase {
  RejectRequestUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<void>> call({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) =>
      _repo.rejectRequest(request: request, adminUid: adminUid);
}

@injectable
class WatchResidentDirectoryUseCase {
  WatchResidentDirectoryUseCase(this._repo);
  final ResidentsRepository _repo;

  Stream<List<UserEntity>> call(String buildingId) => _repo.watchResidentDirectory(buildingId);
}

@injectable
class GetResidentUseCase {
  GetResidentUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<UserEntity?>> call(String uid) => _repo.getResident(uid);
}

@injectable
class GetResidentActivitySummaryUseCase {
  GetResidentActivitySummaryUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<ResidentActivitySummaryEntity>> call({
    required String buildingId,
    required String uid,
  }) =>
      _repo.getResidentActivitySummary(buildingId: buildingId, uid: uid);
}

@injectable
class RemoveResidentUseCase {
  RemoveResidentUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<void>> call({required String uid, required String apartmentId}) =>
      _repo.removeResident(uid: uid, apartmentId: apartmentId);
}

@injectable
class TransferAdminRoleUseCase {
  TransferAdminRoleUseCase(this._repo);
  final ResidentsRepository _repo;

  Future<Result<void>> call({
    required String buildingId,
    required String currentAdminUid,
    required String successorUid,
  }) =>
      _repo.transferAdminRole(
        buildingId: buildingId,
        currentAdminUid: currentAdminUid,
        successorUid: successorUid,
      );
}
