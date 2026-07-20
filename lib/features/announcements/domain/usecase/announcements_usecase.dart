import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/announcements_entity.dart';
import '../repository/announcements_repository.dart';

@injectable
class WatchAnnouncementsUseCase {
  WatchAnnouncementsUseCase(this._repo);
  final AnnouncementsRepository _repo;

  Stream<List<AnnouncementEntity>> call(String buildingId) =>
      _repo.watchAnnouncements(buildingId);
}

@injectable
class CreateAnnouncementUseCase {
  CreateAnnouncementUseCase(this._repo);
  final AnnouncementsRepository _repo;

  Future<Result<void>> call({
    required String buildingId,
    required String title,
    required String body,
    required String createdBy,
  }) {
    return _repo.createAnnouncement(
      buildingId: buildingId,
      title: title,
      body: body,
      createdBy: createdBy,
    );
  }
}

@injectable
class UpdateAnnouncementUseCase {
  UpdateAnnouncementUseCase(this._repo);
  final AnnouncementsRepository _repo;

  Future<Result<void>> call(AnnouncementEntity announcement) =>
      _repo.updateAnnouncement(announcement);
}

@injectable
class DeleteAnnouncementUseCase {
  DeleteAnnouncementUseCase(this._repo);
  final AnnouncementsRepository _repo;

  Future<Result<void>> call(String announcementId) => _repo.deleteAnnouncement(announcementId);
}
