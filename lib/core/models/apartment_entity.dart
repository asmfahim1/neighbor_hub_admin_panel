import 'package:equatable/equatable.dart';

import '../constants/apartment_status.dart';
import '../firebase/firestore_converters.dart';

/// Mirrors `apartments/{apartmentId}` — `05_FIRESTORE_DATABASE.md` §3.3.
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

  factory ApartmentEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    return ApartmentEntity(
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

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'number': number,
        'floor': floor,
        'description': description,
        'status': status.value,
        'primaryResidentUid': primaryResidentUid,
        'updatedAt': FirestoreConverters.fromDate(updatedAt),
      };

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
