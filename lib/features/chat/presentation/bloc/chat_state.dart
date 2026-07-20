import 'package:equatable/equatable.dart';
import '../../domain/entity/chat_entity.dart';

enum ChatStatus { initial, loading, success, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.items = const [],
    this.message,
  });

  final ChatStatus status;
  final List<ChatEntity> items;
  final String? message;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatEntity>? items,
    String? message,
  }) {
    return ChatState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
