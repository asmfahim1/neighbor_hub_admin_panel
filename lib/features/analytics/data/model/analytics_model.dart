import '../../domain/entity/analytics_entity.dart';

class AnalyticsModel {
  AnalyticsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  AnalyticsEntity toEntity() {
    return AnalyticsEntity(id: id, title: title);
  }
}
