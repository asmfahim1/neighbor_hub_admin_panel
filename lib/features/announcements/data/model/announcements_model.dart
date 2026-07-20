import '../../domain/entity/announcements_entity.dart';

class AnnouncementsModel {
  AnnouncementsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory AnnouncementsModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  AnnouncementsEntity toEntity() {
    return AnnouncementsEntity(id: id, title: title);
  }
}
