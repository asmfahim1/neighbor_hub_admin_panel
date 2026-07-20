import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/moderation_entity.dart';
import '../../domain/repository/moderation_repository.dart';
import '../source/moderation_remote_source.dart';

@LazySingleton(as: ModerationRepository)
class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._remote);

  final ModerationRemoteSource _remote;

  @override
  Stream<List<PostEntity>> watchFeed(String buildingId) => _remote.watchFeed(buildingId);

  @override
  Stream<List<CommentEntity>> watchComments(String postId) => _remote.watchComments(postId);

  @override
  Future<Result<PostAuthorshipEntity?>> resolveRealAuthor(String postId) async {
    try {
      return Right(await _remote.fetchAuthorship(postId));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> deletePost(String postId) async {
    try {
      await _remote.deletePost(postId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> deleteComment(String postId, String commentId) async {
    try {
      await _remote.deleteComment(postId, commentId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> setLocked(String postId, bool isLocked) async {
    try {
      await _remote.setLocked(postId, isLocked);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> setPinned(String postId, bool isPinned) async {
    try {
      await _remote.setPinned(postId, isPinned);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
