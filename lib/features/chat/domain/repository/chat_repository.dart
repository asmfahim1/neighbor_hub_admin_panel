import '../../../../core/utils/result.dart';
import '../entity/chat_entity.dart';

abstract class ChatRepository {
  /// Realtime listener on `conversations where participantUids array-contains myUid`.
  Stream<List<ConversationEntity>> watchConversations(String myUid);

  /// Realtime listener on `conversations/{conversationId}/messages`, chronological order.
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  /// Starts (or resumes) a 1:1 conversation with [otherUid], returning the
  /// deterministic conversation id (`FirestorePaths.conversationIdFor`).
  /// Safe to call repeatedly — never clobbers an existing conversation's
  /// `createdAt`/history.
  Future<Result<String>> startOrResumeConversation({
    required String buildingId,
    required String myUid,
    required String otherUid,
  });

  /// Sends a message and updates the parent conversation's `lastMessage`/
  /// `lastMessageAt` in one `WriteBatch`. Best-effort (non-fatal) notifies
  /// the other participant afterward.
  Future<Result<void>> sendMessage({
    required String conversationId,
    required String senderUid,
    required String recipientUid,
    required String buildingId,
    required String text,
  });
}
