import 'package:injectable/injectable.dart';

import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_service.dart';
import '../../../../core/models/data_models.dart';
import '../../../../core/models/models.dart';

/// The swappable "endpoint" boundary for the Moderation feature. A future
/// custom backend adds `ModerationApiSource implements ModerationRemoteSource`
/// and flips the DI binding — nothing in `domain/` or `data/repository` changes.
abstract class ModerationRemoteSource {
  Stream<List<PostEntity>> watchFeed(String buildingId);
  Stream<List<CommentEntity>> watchComments(String postId);
  Future<PostAuthorshipEntity?> fetchAuthorship(String postId);
  Future<void> deletePost(String postId);
  Future<void> deleteComment(String postId, String commentId);
  Future<void> setLocked(String postId, bool isLocked);
  Future<void> setPinned(String postId, bool isPinned);
}

@LazySingleton(as: ModerationRemoteSource)
class ModerationFirestoreSource implements ModerationRemoteSource {
  ModerationFirestoreSource(this._firestore);

  final FirestoreService _firestore;

  @override
  Stream<List<PostEntity>> watchFeed(String buildingId) {
    final query = _firestore
        .buildingScoped(FirestoreCollections.posts, buildingId)
        .orderBy(FirestoreFields.createdAt, descending: true);
    return _firestore.watchQuery(query).map(
          (snapshot) =>
              snapshot.docs.map((doc) => PostModel.fromJson(doc.data(), id: doc.id)).toList(),
        );
  }

  @override
  Stream<List<CommentEntity>> watchComments(String postId) {
    final query = _firestore
        .collection(FirestorePaths.postComments(postId))
        .orderBy(FirestoreFields.createdAt, descending: false);
    return _firestore.watchQuery(query).map(
          (snapshot) => snapshot.docs
              .map((doc) => CommentModel.fromJson(doc.data(), id: doc.id, postId: postId))
              .toList(),
        );
  }

  @override
  Future<PostAuthorshipEntity?> fetchAuthorship(String postId) async {
    final snapshot = await _firestore.getDocument(FirestorePaths.postAuthorship(postId));
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return PostAuthorshipModel.fromJson(data, postId: postId);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _firestore.deleteDocument(FirestorePaths.post(postId));
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await _firestore.deleteDocument(FirestorePaths.postComment(postId, commentId));
  }

  @override
  Future<void> setLocked(String postId, bool isLocked) async {
    await _firestore.updateDocument(FirestorePaths.post(postId), {
      'isLocked': isLocked,
      'updatedAt': _firestore.serverTimestamp,
    });
  }

  @override
  Future<void> setPinned(String postId, bool isPinned) async {
    await _firestore.updateDocument(FirestorePaths.post(postId), {
      'isPinned': isPinned,
      'updatedAt': _firestore.serverTimestamp,
    });
  }
}
