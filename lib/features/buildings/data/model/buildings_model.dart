import '../../domain/entity/buildings_entity.dart';

class BuildingsModel {
  BuildingsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory BuildingsModel.fromJson(Map<String, dynamic> json) {
    return BuildingsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  BuildingsEntity toEntity() {
    return BuildingsEntity(id: id, title: title);
  }
}
