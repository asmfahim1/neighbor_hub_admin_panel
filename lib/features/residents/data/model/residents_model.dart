import '../../domain/entity/residents_entity.dart';

class ResidentsModel {
  ResidentsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ResidentsModel.fromJson(Map<String, dynamic> json) {
    return ResidentsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ResidentsEntity toEntity() {
    return ResidentsEntity(id: id, title: title);
  }
}
