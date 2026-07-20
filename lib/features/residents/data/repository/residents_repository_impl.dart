import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/residents_entity.dart';
import '../../domain/repository/residents_repository.dart';
import '../source/residents_remote_source.dart';

@LazySingleton(as: ResidentsRepository)
class ResidentsRepositoryImpl implements ResidentsRepository {
  ResidentsRepositoryImpl(this._remote);

  final ResidentsRemoteSource _remote;

  @override
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId) =>
      _remote.watchPendingRequests(buildingId);

  @override
  Future<Result<void>> approveRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) async {
    try {
      await _remote.approveRequest(request: request, adminUid: adminUid);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> rejectRequest({
    required ApartmentRequestEntity request,
    required String adminUid,
  }) async {
    try {
      await _remote.rejectRequest(request: request, adminUid: adminUid);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Stream<List<UserEntity>> watchResidentDirectory(String buildingId) =>
      _remote.watchResidentDirectory(buildingId);

  @override
  Future<Result<UserEntity?>> getResident(String uid) async {
    try {
      return Right(await _remote.fetchUser(uid));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<ResidentActivitySummaryEntity>> getResidentActivitySummary({
    required String buildingId,
    required String uid,
  }) async {
    try {
      final posts = await _remote.fetchPostsForActivitySummary(buildingId);
      final authored = posts.where((post) => post.authorUid == uid);
      final summary = ResidentActivitySummaryEntity(
        postCount: authored.length,
        commentCount: authored.fold<int>(0, (sum, post) => sum + post.commentCount),
        reactionCount: authored.fold<int>(0, (sum, post) => sum + post.reactionCount),
      );
      return Right(summary);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> removeResident({
    required String uid,
    required String apartmentId,
  }) async {
    try {
      await _remote.removeResident(uid: uid, apartmentId: apartmentId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> transferAdminRole({
    required String buildingId,
    required String currentAdminUid,
    required String successorUid,
  }) async {
    try {
      await _remote.transferAdminRole(
        buildingId: buildingId,
        currentAdminUid: currentAdminUid,
        successorUid: successorUid,
      );
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
