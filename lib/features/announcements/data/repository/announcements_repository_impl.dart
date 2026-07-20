import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/announcements_entity.dart';
import '../../domain/repository/announcements_repository.dart';
import '../source/announcements_remote_source.dart';

@LazySingleton(as: AnnouncementsRepository)
class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl(this._remote);

  final AnnouncementsRemoteSource _remote;

  @override
  Stream<List<AnnouncementEntity>> watchAnnouncements(String buildingId) =>
      _remote.watchAnnouncements(buildingId);

  @override
  Future<Result<void>> createAnnouncement({
    required String buildingId,
    required String title,
    required String body,
    required String createdBy,
  }) async {
    try {
      await _remote.createAnnouncement(
        buildingId: buildingId,
        title: title,
        body: body,
        createdBy: createdBy,
      );
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> updateAnnouncement(AnnouncementEntity announcement) async {
    try {
      await _remote.updateAnnouncement(announcement);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> deleteAnnouncement(String announcementId) async {
    try {
      await _remote.deleteAnnouncement(announcementId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
