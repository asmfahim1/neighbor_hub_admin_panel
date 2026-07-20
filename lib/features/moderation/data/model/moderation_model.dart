import '../../domain/entity/moderation_entity.dart';

class ModerationModel {
  ModerationModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ModerationModel.fromJson(Map<String, dynamic> json) {
    return ModerationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ModerationEntity toEntity() {
    return ModerationEntity(id: id, title: title);
  }
}
