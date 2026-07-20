import '../../domain/entity/profile_entity.dart';

class ProfileModel {
  ProfileModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(id: id, title: title);
  }
}
