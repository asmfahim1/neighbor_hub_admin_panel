import 'apartment_entity.dart';
import '../constants/apartment_status.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `apartments/{apartmentId}`. See
/// `lib/core/models/README.md` for why Model extends Entity.
class ApartmentModel extends ApartmentEntity {
  const ApartmentModel({
    required super.id,
    required super.buildingId,
    required super.number,
    required super.floor,
    super.description,
    required super.status,
    super.primaryResidentUid,
    required super.updatedAt,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return ApartmentModel(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      status: ApartmentStatus.fromValue(json['status']?.toString()),
      primaryResidentUid: json['primaryResidentUid']?.toString(),
      updatedAt: FirestoreConverters.toDateOrNow(json['updatedAt']),
    );
  }

  factory ApartmentModel.fromEntity(ApartmentEntity entity) {
    return ApartmentModel(
      id: entity.id,
      buildingId: entity.buildingId,
      number: entity.number,
      floor: entity.floor,
      description: entity.description,
      status: entity.status,
      primaryResidentUid: entity.primaryResidentUid,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'number': number,
        'floor': floor,
        'description': description,
        'status': status.value,
        'primaryResidentUid': primaryResidentUid,
        'updatedAt': FirestoreConverters.fromDate(updatedAt),
      };
}
