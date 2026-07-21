import 'building_entity.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `buildings/{buildingId}` — the only class that knows
/// about the Firestore wire format. Extends [BuildingEntity] so every
/// remote source/repository can hand a `BuildingModel` anywhere a
/// `BuildingEntity` is expected (Liskov substitution) while the domain
/// layer never sees `fromJson`/`toJson`.
class BuildingModel extends BuildingEntity {
  const BuildingModel({
    required super.id,
    required super.name,
    required super.address,
    required super.totalFloors,
    required super.apartmentsPerFloor,
    super.adminUid,
    required super.createdAt,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return BuildingModel(
      id: id,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      totalFloors: (json['totalFloors'] as num?)?.toInt() ?? 0,
      apartmentsPerFloor: (json['apartmentsPerFloor'] as num?)?.toInt() ?? 0,
      adminUid: json['adminUid']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  /// Wraps a plain [BuildingEntity] (e.g. one built by the domain/bloc layer)
  /// so it can be serialized for a write.
  factory BuildingModel.fromEntity(BuildingEntity entity) {
    return BuildingModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      totalFloors: entity.totalFloors,
      apartmentsPerFloor: entity.apartmentsPerFloor,
      adminUid: entity.adminUid,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'totalFloors': totalFloors,
        'apartmentsPerFloor': apartmentsPerFloor,
        if (adminUid != null) 'adminUid': adminUid,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
