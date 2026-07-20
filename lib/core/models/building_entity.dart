import 'package:equatable/equatable.dart';

import '../firebase/firestore_converters.dart';

/// Mirrors `buildings/{buildingId}` — `05_FIRESTORE_DATABASE.md` §3.1,
/// plus the `adminUid` addendum from `admen_web_app_ui_functionality.md` §6.1.
///
/// Canonical, framework-agnostic data class — shared by every feature that
/// touches `buildings` and copy-paste ready for the future Resident App.
/// `fromJson`/`toJson` are the only Firestore-shaped boundary; everything
/// else in the app works with plain fields.
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

  factory BuildingEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    return BuildingEntity(
      id: id,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      totalFloors: (json['totalFloors'] as num?)?.toInt() ?? 0,
      apartmentsPerFloor: (json['apartmentsPerFloor'] as num?)?.toInt() ?? 0,
      adminUid: json['adminUid']?.toString(),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
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
