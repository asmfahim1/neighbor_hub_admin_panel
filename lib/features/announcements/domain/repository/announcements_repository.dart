import '../../../../core/utils/result.dart';
import '../entity/announcements_entity.dart';

abstract class AnnouncementsRepository {
  Future<Result<List<AnnouncementsEntity>>> getAnnouncementsData();
}
