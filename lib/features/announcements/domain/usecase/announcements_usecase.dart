import '../../../../core/utils/result.dart';
import '../entity/announcements_entity.dart';
import '../repository/announcements_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class AnnouncementsUseCase {
  AnnouncementsUseCase(this._repo);

  final AnnouncementsRepository _repo;

  Future<Result<List<AnnouncementsEntity>>> call() {
    return _repo.getAnnouncementsData();
  }
}
