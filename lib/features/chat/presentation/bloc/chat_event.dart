import 'package:equatable/equatable.dart';

import '../../../../core/models/models.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConversationsWatchStarted extends ChatEvent {
  const ConversationsWatchStarted(this.myUid);
  final String myUid;

  @override
  List<Object?> get props => [myUid];
}

/// Internal — emitted by the conversations-list stream subscription.
class ConversationsUpdated extends ChatEvent {
  const ConversationsUpdated(this.conversations);
  final List<ConversationEntity> conversations;

  @override
  List<Object?> get props => [conversations];
}

/// Opens (and starts watching messages for) a conversation. Cancels any
/// previously-open conversation's message subscription.
class ConversationOpened extends ChatEvent {
  const ConversationOpened(this.conversationId);
  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class ConversationClosed extends ChatEvent {
  const ConversationClosed();
}

/// Internal — emitted by the open conversation's messages stream subscription.
class MessagesUpdated extends ChatEvent {
  const MessagesUpdated(this.messages);
  final List<MessageEntity> messages;

  @override
  List<Object?> get props => [messages];
}

/// Starts (or resumes) a 1:1 conversation with [otherUid] — e.g. tapping a
/// contact in the Resident Directory (§7.5.2).
class ConversationStartRequested extends ChatEvent {
  const ConversationStartRequested({
    required this.buildingId,
    required this.myUid,
    required this.otherUid,
  });

  final String buildingId;
  final String myUid;
  final String otherUid;

  @override
  List<Object?> get props => [buildingId, myUid, otherUid];
}

class MessageSendRequested extends ChatEvent {
  const MessageSendRequested({
    required this.conversationId,
    required this.senderUid,
    required this.recipientUid,
    required this.buildingId,
    required this.text,
  });

  final String conversationId;
  final String senderUid;
  final String recipientUid;
  final String buildingId;
  final String text;

  @override
  List<Object?> get props => [conversationId, senderUid, recipientUid, buildingId, text];
}

/// Internal — any listener errored.
class ChatFailed extends ChatEvent {
  const ChatFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
