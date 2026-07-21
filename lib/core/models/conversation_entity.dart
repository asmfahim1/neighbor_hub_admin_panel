import 'package:equatable/equatable.dart';

/// Mirrors `conversations/{conversationId}` — `05_FIRESTORE_DATABASE.md` §3.14.
/// Document ID is the two participant uids, sorted and joined.
///
/// Pure domain object — no Firestore/JSON knowledge. See
/// [ConversationModel] (`conversation_model.dart`) for parsing/serialization.
class ConversationEntity extends Equatable {
  const ConversationEntity({
    required this.id,
    required this.buildingId,
    required this.participantUids,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    this.otherParticipantName,
  });

  final String id;
  final String buildingId;
  final List<String> participantUids;
  final String lastMessage;
  final DateTime lastMessageAt;
  final DateTime createdAt;

  /// Not part of the Firestore document — resolved from `users/{uid}.displayName`
  /// of the other participant, for the Chat List UI.
  final String? otherParticipantName;

  String otherParticipant(String myUid) =>
      participantUids.firstWhere((uid) => uid != myUid, orElse: () => '');

  @override
  List<Object?> get props =>
      [id, buildingId, participantUids, lastMessage, lastMessageAt, createdAt];
}

/// Mirrors `conversations/{conversationId}/messages/{messageId}` —
/// `05_FIRESTORE_DATABASE.md` §3.15. Pure domain object — see [MessageModel]
/// for parsing/serialization.
class MessageEntity extends Equatable {
  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderUid,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderUid;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, conversationId, senderUid, text, createdAt];
}
