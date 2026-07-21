import 'package:equatable/equatable.dart';

import '../constants/apartment_status.dart';

/// Mirrors `apartments/{apartmentId}` — `05_FIRESTORE_DATABASE.md` §3.3.
///
/// Pure domain object — no Firestore/JSON knowledge. See [ApartmentModel]
/// (`apartment_model.dart`) for parsing/serialization.
class ApartmentEntity extends Equatable {
  const ApartmentEntity({
    required this.id,
    required this.buildingId,
    required this.number,
    required this.floor,
    this.description,
    required this.status,
    this.primaryResidentUid,
    required this.updatedAt,
  });

  final String id;
  final String buildingId;
  final String number;
  final int floor;
  final String? description;
  final ApartmentStatus status;

  /// Set when [status] is [ApartmentStatus.occupied]; mirrors `users/{uid}.apartmentId`.
  final String? primaryResidentUid;
  final DateTime updatedAt;

  ApartmentEntity copyWith({
    String? number,
    int? floor,
    String? description,
    ApartmentStatus? status,
    String? primaryResidentUid,
    DateTime? updatedAt,
  }) {
    return ApartmentEntity(
      id: id,
      buildingId: buildingId,
      number: number ?? this.number,
      floor: floor ?? this.floor,
      description: description ?? this.description,
      status: status ?? this.status,
      primaryResidentUid: primaryResidentUid ?? this.primaryResidentUid,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, buildingId, number, floor, description, status, primaryResidentUid, updatedAt];
}
