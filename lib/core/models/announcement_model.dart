import 'announcement_entity.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `announcements/{announcementId}`. See
/// `lib/core/models/README.md` for why Model extends Entity.
class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.buildingId,
    required super.title,
    required super.body,
    required super.createdBy,
    required super.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return AnnouncementModel(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory AnnouncementModel.fromEntity(AnnouncementEntity entity) {
    return AnnouncementModel(
      id: entity.id,
      buildingId: entity.buildingId,
      title: entity.title,
      body: entity.body,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'title': title,
        'body': body,
        'createdBy': createdBy,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
