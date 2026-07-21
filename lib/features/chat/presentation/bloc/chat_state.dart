import 'package:equatable/equatable.dart';

import '../../domain/entity/chat_entity.dart';

enum ChatStatus { initial, loading, loaded, sending, failure }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.conversations = const [],
    this.openConversationId,
    this.messages = const [],
    this.message,
  });

  final ChatStatus status;
  final List<ConversationEntity> conversations;
  final String? openConversationId;
  final List<MessageEntity> messages;

  /// Human-readable error copy — unrelated to [messages] (the chat thread).
  final String? message;

  ChatState copyWith({
    ChatStatus? status,
    List<ConversationEntity>? conversations,
    String? openConversationId,
    bool clearOpenConversationId = false,
    List<MessageEntity>? messages,
    String? message,
    bool clearMessage = false,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      openConversationId:
          clearOpenConversationId ? null : (openConversationId ?? this.openConversationId),
      messages: messages ?? this.messages,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, conversations, openConversationId, messages, message];
}
