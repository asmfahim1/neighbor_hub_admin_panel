import '../../domain/entity/apartments_entity.dart';

class ApartmentsModel {
  ApartmentsModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ApartmentsModel.fromJson(Map<String, dynamic> json) {
    return ApartmentsModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ApartmentsEntity toEntity() {
    return ApartmentsEntity(id: id, title: title);
  }
}
