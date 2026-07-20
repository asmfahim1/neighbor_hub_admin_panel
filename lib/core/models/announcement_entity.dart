import 'package:equatable/equatable.dart';

import '../firebase/firestore_converters.dart';

/// Mirrors `announcements/{announcementId}` — `05_FIRESTORE_DATABASE.md` §3.10.
/// Always attributed to "Building Management" in the UI, never anonymous.
class AnnouncementEntity extends Equatable {
  const AnnouncementEntity({
    required this.id,
    required this.buildingId,
    required this.title,
    required this.body,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String buildingId;
  final String title;
  final String body;
  final String createdBy;
  final DateTime createdAt;

  factory AnnouncementEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    return AnnouncementEntity(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'title': title,
        'body': body,
        'createdBy': createdBy,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  AnnouncementEntity copyWith({String? title, String? body}) {
    return AnnouncementEntity(
      id: id,
      buildingId: buildingId,
      title: title ?? this.title,
      body: body ?? this.body,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, buildingId, title, body, createdBy, createdAt];
}
