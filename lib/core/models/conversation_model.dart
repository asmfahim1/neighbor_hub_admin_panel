import 'conversation_entity.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `conversations/{conversationId}`. See
/// `lib/core/models/README.md` for why Model extends Entity.
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.buildingId,
    required super.participantUids,
    required super.lastMessage,
    required super.lastMessageAt,
    required super.createdAt,
    super.otherParticipantName,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final rawParticipants = json['participantUids'] as List<dynamic>? ?? const [];
    return ConversationModel(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      participantUids: rawParticipants.map((e) => e.toString()).toList(),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageAt: FirestoreConverters.toDateOrNow(json['lastMessageAt']),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory ConversationModel.fromEntity(ConversationEntity entity) {
    return ConversationModel(
      id: entity.id,
      buildingId: entity.buildingId,
      participantUids: entity.participantUids,
      lastMessage: entity.lastMessage,
      lastMessageAt: entity.lastMessageAt,
      createdAt: entity.createdAt,
      otherParticipantName: entity.otherParticipantName,
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'participantUids': participantUids,
        'lastMessage': lastMessage,
        'lastMessageAt': FirestoreConverters.fromDate(lastMessageAt),
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}

/// Data-layer DTO for `conversations/{conversationId}/messages/{messageId}`.
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderUid,
    required super.text,
    required super.createdAt,
  });

  factory MessageModel.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String conversationId,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderUid: json['senderUid']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      conversationId: entity.conversationId,
      senderUid: entity.senderUid,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'senderUid': senderUid,
        'text': text,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
