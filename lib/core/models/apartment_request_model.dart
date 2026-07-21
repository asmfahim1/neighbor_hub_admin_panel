import 'apartment_request_entity.dart';
import '../constants/apartment_request_status.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `apartment_requests/{uid}`. See
/// `lib/core/models/README.md` for why Model extends Entity.
class ApartmentRequestModel extends ApartmentRequestEntity {
  const ApartmentRequestModel({
    required super.uid,
    required super.buildingId,
    required super.apartmentId,
    super.familyNote,
    required super.status,
    super.decidedBy,
    required super.createdAt,
    super.decidedAt,
    super.requesterDisplayName,
  });

  factory ApartmentRequestModel.fromJson(
    Map<String, dynamic> json, {
    required String uid,
    String? requesterDisplayName,
  }) {
    return ApartmentRequestModel(
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

  factory ApartmentRequestModel.fromEntity(ApartmentRequestEntity entity) {
    return ApartmentRequestModel(
      uid: entity.uid,
      buildingId: entity.buildingId,
      apartmentId: entity.apartmentId,
      familyNote: entity.familyNote,
      status: entity.status,
      decidedBy: entity.decidedBy,
      createdAt: entity.createdAt,
      decidedAt: entity.decidedAt,
      requesterDisplayName: entity.requesterDisplayName,
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
}
