import '../../../../core/utils/result.dart';
import '../entity/moderation_entity.dart';

abstract class ModerationRepository {
  /// Realtime listener on all `posts where buildingId == X`, admin view
  /// (includes `isPinned`/`isLocked`), ordered `createdAt desc`.
  Stream<List<PostEntity>> watchFeed(String buildingId);

  /// Realtime listener on `posts/{postId}/comments`, chronological order.
  Stream<List<CommentEntity>> watchComments(String postId);

  /// Resolves the real author of [postId] via `post_authorship/{postId}` —
  /// always the true author, regardless of the public post's `isAnonymous`.
  /// Admin-only; never bulk-fetched with the feed list.
  Future<Result<PostAuthorshipEntity?>> resolveRealAuthor(String postId);

  Future<Result<void>> deletePost(String postId);

  Future<Result<void>> deleteComment(String postId, String commentId);

  /// `isLocked → true` blocks new comments; existing comments stay visible
  /// (enforced by Firestore rules, this is just the field write).
  Future<Result<void>> setLocked(String postId, bool isLocked);

  /// `isPinned → true` moves the post to the top of the resident feed.
  Future<Result<void>> setPinned(String postId, bool isPinned);
}
