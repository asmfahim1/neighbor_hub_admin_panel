import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/moderation_entity.dart';
import '../repository/moderation_repository.dart';

@injectable
class WatchModerationFeedUseCase {
  WatchModerationFeedUseCase(this._repo);
  final ModerationRepository _repo;

  Stream<List<PostEntity>> call(String buildingId) => _repo.watchFeed(buildingId);
}

@injectable
class WatchPostCommentsUseCase {
  WatchPostCommentsUseCase(this._repo);
  final ModerationRepository _repo;

  Stream<List<CommentEntity>> call(String postId) => _repo.watchComments(postId);
}

@injectable
class ResolveRealAuthorUseCase {
  ResolveRealAuthorUseCase(this._repo);
  final ModerationRepository _repo;

  Future<Result<PostAuthorshipEntity?>> call(String postId) => _repo.resolveRealAuthor(postId);
}

@injectable
class DeletePostUseCase {
  DeletePostUseCase(this._repo);
  final ModerationRepository _repo;

  Future<Result<void>> call(String postId) => _repo.deletePost(postId);
}

@injectable
class DeleteCommentUseCase {
  DeleteCommentUseCase(this._repo);
  final ModerationRepository _repo;

  Future<Result<void>> call(String postId, String commentId) =>
      _repo.deleteComment(postId, commentId);
}

@injectable
class SetPostLockedUseCase {
  SetPostLockedUseCase(this._repo);
  final ModerationRepository _repo;

  Future<Result<void>> call(String postId, bool isLocked) => _repo.setLocked(postId, isLocked);
}

@injectable
class SetPostPinnedUseCase {
  SetPostPinnedUseCase(this._repo);
  final ModerationRepository _repo;

  Future<Result<void>> call(String postId, bool isPinned) => _repo.setPinned(postId, isPinned);
}
