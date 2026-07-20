import '../../domain/entity/notifications_entity.dart';

class NotificationsModel {
  NotificationsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    return NotificationsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  NotificationsEntity toEntity() {
    return NotificationsEntity(id: id, title: title);
  }
}
