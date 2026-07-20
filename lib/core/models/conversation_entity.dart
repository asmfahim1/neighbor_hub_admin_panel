import 'package:equatable/equatable.dart';

import '../firebase/firestore_converters.dart';

/// Mirrors `conversations/{conversationId}` — `05_FIRESTORE_DATABASE.md` §3.14.
/// Document ID is the two participant uids, sorted and joined.
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

  factory ConversationEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    final rawParticipants = json['participantUids'] as List<dynamic>? ?? const [];
    return ConversationEntity(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      participantUids: rawParticipants.map((e) => e.toString()).toList(),
      lastMessage: json['lastMessage']?.toString() ?? '',
      lastMessageAt: FirestoreConverters.toDateOrNow(json['lastMessageAt']),
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'participantUids': participantUids,
        'lastMessage': lastMessage,
        'lastMessageAt': FirestoreConverters.fromDate(lastMessageAt),
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props =>
      [id, buildingId, participantUids, lastMessage, lastMessageAt, createdAt];
}

/// Mirrors `conversations/{conversationId}/messages/{messageId}` —
/// `05_FIRESTORE_DATABASE.md` §3.15.
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

  factory MessageEntity.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String conversationId,
  }) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderUid: json['senderUid']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'senderUid': senderUid,
        'text': text,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [id, conversationId, senderUid, text, createdAt];
}
