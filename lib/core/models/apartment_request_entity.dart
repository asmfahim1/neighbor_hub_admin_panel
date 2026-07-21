import 'package:equatable/equatable.dart';

import '../constants/apartment_request_status.dart';

/// Mirrors `apartment_requests/{uid}` — `05_FIRESTORE_DATABASE.md` §3.4.
///
/// Document ID is the requester's uid — see [uid]. Pure domain object — no
/// Firestore/JSON knowledge. See [ApartmentRequestModel]
/// (`apartment_request_model.dart`) for parsing/serialization.
class ApartmentRequestEntity extends Equatable {
  const ApartmentRequestEntity({
    required this.uid,
    required this.buildingId,
    required this.apartmentId,
    this.familyNote,
    required this.status,
    this.decidedBy,
    required this.createdAt,
    this.decidedAt,
    this.requesterDisplayName,
  });

  final String uid;
  final String buildingId;
  final String apartmentId;
  final String? familyNote;
  final ApartmentRequestStatus status;
  final String? decidedBy;
  final DateTime createdAt;
  final DateTime? decidedAt;

  /// Not part of the Firestore document — resolved from `users/{uid}.displayName`
  /// by the repository for display in the Pending Request Queue (§7.5.1).
  final String? requesterDisplayName;

  ApartmentRequestEntity copyWith({
    ApartmentRequestStatus? status,
    String? decidedBy,
    DateTime? decidedAt,
    String? requesterDisplayName,
  }) {
    return ApartmentRequestEntity(
      uid: uid,
      buildingId: buildingId,
      apartmentId: apartmentId,
      familyNote: familyNote,
      status: status ?? this.status,
      decidedBy: decidedBy ?? this.decidedBy,
      createdAt: createdAt,
      decidedAt: decidedAt ?? this.decidedAt,
      requesterDisplayName: requesterDisplayName ?? this.requesterDisplayName,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        buildingId,
        apartmentId,
        familyNote,
        status,
        decidedBy,
        createdAt,
        decidedAt,
        requesterDisplayName,
      ];
}
