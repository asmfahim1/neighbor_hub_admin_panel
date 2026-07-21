import 'package:equatable/equatable.dart';

/// Mirrors `buildings/{buildingId}` — `05_FIRESTORE_DATABASE.md` §3.1,
/// plus the `adminUid` addendum from `admen_web_app_ui_functionality.md` §6.1.
///
/// Pure domain object — no Firestore/JSON knowledge. Parsing/serialization
/// lives on [BuildingModel] (`building_model.dart`), the data-layer class
/// that extends this one. See `lib/core/models/README.md`.
class BuildingEntity extends Equatable {
  const BuildingEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.totalFloors,
    required this.apartmentsPerFloor,
    this.adminUid,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String address;
  final int totalFloors;
  final int apartmentsPerFloor;
  final String? adminUid;
  final DateTime createdAt;

  BuildingEntity copyWith({
    String? name,
    String? address,
    int? totalFloors,
    int? apartmentsPerFloor,
    String? adminUid,
  }) {
    return BuildingEntity(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      totalFloors: totalFloors ?? this.totalFloors,
      apartmentsPerFloor: apartmentsPerFloor ?? this.apartmentsPerFloor,
      adminUid: adminUid ?? this.adminUid,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, address, totalFloors, apartmentsPerFloor, adminUid, createdAt];
}
