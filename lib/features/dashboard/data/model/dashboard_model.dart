import '../../domain/entity/dashboard_entity.dart';

class DashboardModel {
  DashboardModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  DashboardEntity toEntity() {
    return DashboardEntity(id: id, title: title);
  }
}
