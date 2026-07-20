import '../../domain/entity/chat_entity.dart';

class ChatModel {
  ChatModel({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
    );
  }

  ChatEntity toEntity() {
    return ChatEntity(id: id, title: title);
  }
}
