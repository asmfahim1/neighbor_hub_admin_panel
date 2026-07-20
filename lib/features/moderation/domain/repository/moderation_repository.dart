import '../../../../core/utils/result.dart';
import '../entity/moderation_entity.dart';

abstract class ModerationRepository {
  Future<Result<List<ModerationEntity>>> getModerationData();
}
