import 'package:equatable/equatable.dart';

import '../../domain/entity/residents_entity.dart';

abstract class ResidentsEvent extends Equatable {
  const ResidentsEvent();

  @override
  List<Object?> get props => [];
}

// --- 7.5.1 Pending Request Queue ---

class PendingRequestsWatchStarted extends ResidentsEvent {
  const PendingRequestsWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the pending-requests stream subscription.
class PendingRequestsUpdated extends ResidentsEvent {
  const PendingRequestsUpdated(this.requests);
  final List<ApartmentRequestEntity> requests;

  @override
  List<Object?> get props => [requests];
}

class RequestApproveRequested extends ResidentsEvent {
  const RequestApproveRequested({required this.request, required this.adminUid});
  final ApartmentRequestEntity request;
  final String adminUid;

  @override
  List<Object?> get props => [request, adminUid];
}

class RequestRejectRequested extends ResidentsEvent {
  const RequestRejectRequested({required this.request, required this.adminUid});
  final ApartmentRequestEntity request;
  final String adminUid;

  @override
  List<Object?> get props => [request, adminUid];
}

// --- 7.5.2 Resident Directory ---

class DirectoryWatchStarted extends ResidentsEvent {
  const DirectoryWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the directory stream subscription.
class DirectoryUpdated extends ResidentsEvent {
  const DirectoryUpdated(this.residents);
  final List<UserEntity> residents;

  @override
  List<Object?> get props => [residents];
}

// --- 7.5.3 Resident Detail & Removal ---

class ResidentDetailRequested extends ResidentsEvent {
  const ResidentDetailRequested({required this.uid, required this.buildingId});
  final String uid;
  final String buildingId;

  @override
  List<Object?> get props => [uid, buildingId];
}

class ResidentRemoveRequested extends ResidentsEvent {
  const ResidentRemoveRequested({required this.uid, required this.apartmentId});
  final String uid;
  final String apartmentId;

  @override
  List<Object?> get props => [uid, apartmentId];
}

// --- 7.5.4 Transfer Admin Role ---

class TransferAdminRoleRequested extends ResidentsEvent {
  const TransferAdminRoleRequested({
    required this.buildingId,
    required this.currentAdminUid,
    required this.successorUid,
  });
  final String buildingId;
  final String currentAdminUid;
  final String successorUid;

  @override
  List<Object?> get props => [buildingId, currentAdminUid, successorUid];
}

/// Internal — any mutation/fetch failed.
class ResidentsFailed extends ResidentsEvent {
  const ResidentsFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
