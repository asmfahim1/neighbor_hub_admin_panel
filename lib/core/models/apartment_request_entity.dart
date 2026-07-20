import 'package:equatable/equatable.dart';

import '../constants/apartment_request_status.dart';
import '../firebase/firestore_converters.dart';

/// Mirrors `apartment_requests/{uid}` — `05_FIRESTORE_DATABASE.md` §3.4.
///
/// Document ID is the requester's uid — see [uid].
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

  factory ApartmentRequestEntity.fromJson(
    Map<String, dynamic> json, {
    required String uid,
    String? requesterDisplayName,
  }) {
    return ApartmentRequestEntity(
      uid: uid,
      buildingId: json['buildingId']?.toString() ?? '',
      apartmentId: json['apartmentId']?.toString() ?? '',
      familyNote: json['familyNote']?.toString(),
      status: ApartmentRequestStatus.fromValue(json['status']?.toString()),
      decidedBy: json['decidedBy']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
      decidedAt: FirestoreConverters.toDate(json['decidedAt']),
      requesterDisplayName: requesterDisplayName,
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'apartmentId': apartmentId,
        'familyNote': familyNote,
        'status': status.value,
        'decidedBy': decidedBy,
        'createdAt': FirestoreConverters.fromDate(createdAt),
        'decidedAt': FirestoreConverters.fromDate(decidedAt),
      };

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
