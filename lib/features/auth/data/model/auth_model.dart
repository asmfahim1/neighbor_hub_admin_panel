import '../../domain/entity/auth_entity.dart';

class AuthModel {
  AuthModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(id: id, title: title);
  }
}
