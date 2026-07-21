import 'package:equatable/equatable.dart';

/// Mirrors `announcements/{announcementId}` — `05_FIRESTORE_DATABASE.md` §3.10.
/// Always attributed to "Building Management" in the UI, never anonymous.
///
/// Pure domain object — no Firestore/JSON knowledge. See
/// [AnnouncementModel] (`announcement_model.dart`) for parsing/serialization.
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
