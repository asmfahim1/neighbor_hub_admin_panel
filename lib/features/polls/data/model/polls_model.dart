import '../../domain/entity/polls_entity.dart';

class PollsModel {
  PollsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory PollsModel.fromJson(Map<String, dynamic> json) {
    return PollsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  PollsEntity toEntity() {
    return PollsEntity(id: id, title: title);
  }
}
