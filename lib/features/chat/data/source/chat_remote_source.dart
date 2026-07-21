import 'package:injectable/injectable.dart';

import '../../../../core/constants/notification_category.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/conversation_model.dart';
import '../../../../core/models/models.dart';

/// The swappable "endpoint" boundary for the Chat feature. A future custom
/// backend adds `ChatApiSource implements ChatRemoteSource` and flips the DI
/// binding — nothing in `domain/` or `data/repository` changes.
abstract class ChatRemoteSource {
  Stream<List<ConversationEntity>> watchConversations(String myUid);
  Stream<List<MessageEntity>> watchMessages(String conversationId);

  Future<String> startOrResumeConversation({
    required String buildingId,
    required String myUid,
    required String otherUid,
  });

  Future<void> sendMessage({
    required String conversationId,
    required String senderUid,
    required String recipientUid,
    required String buildingId,
    required String text,
  });
}

@LazySingleton(as: ChatRemoteSource)
class ChatFirestoreSource implements ChatRemoteSource {
  ChatFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<ConversationEntity>> watchConversations(String myUid) {
    final query = _firestore
        .collection(FirestoreCollections.conversations)
        .where('participantUids', arrayContains: myUid);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromJson(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Stream<List<MessageEntity>> watchMessages(String conversationId) {
    final query = _firestore
        .collection(FirestorePaths.conversationMessages(conversationId))
        .orderBy(FirestoreFields.createdAt);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(
                    doc.data(),
                    id: doc.id,
                    conversationId: conversationId,
                  ))
              .toList(),
        );
  }

  @override
  Future<String> startOrResumeConversation({
    required String buildingId,
    required String myUid,
    required String otherUid,
  }) async {
    final conversationId = FirestorePaths.conversationIdFor(myUid, otherUid);
    final path = FirestorePaths.conversation(conversationId);
    final existing = await _firestore.getDocument(path);
    if (!existing.exists) {
      await _firestore.setDocument(path, {
        'buildingId': buildingId,
        'participantUids': [myUid, otherUid],
        'lastMessage': '',
        'lastMessageAt': _firestore.serverTimestamp,
        'createdAt': _firestore.serverTimestamp,
      });
    }
    return conversationId;
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String senderUid,
    required String recipientUid,
    required String buildingId,
    required String text,
  }) async {
    final batch = _firestore.newBatch();

    final messageRef = _firestore.collection(
      FirestorePaths.conversationMessages(conversationId),
    ).doc();
    batch.set(messageRef, {
      'senderUid': senderUid,
      'text': text,
      'createdAt': _firestore.serverTimestamp,
    });

    final conversationRef = _firestore.document(FirestorePaths.conversation(conversationId));
    batch.update(conversationRef, {
      'lastMessage': text,
      'lastMessageAt': _firestore.serverTimestamp,
    });

    await _firestore.commitBatch(batch);

    // Best-effort — a notification failure must never fail the send itself.
    try {
      await _firestore.addDocument(FirestoreCollections.notifications, {
        'recipientUid': recipientUid,
        'buildingId': buildingId,
        'category': NotificationCategory.chat.value,
        'title': 'New message',
        'body': text,
        'relatedPostId': null,
        'relatedConversationId': conversationId,
        'isRead': false,
        'createdAt': _firestore.serverTimestamp,
      });
    } catch (_) {
      // Swallowed intentionally — see doc comment above.
    }
  }
}
