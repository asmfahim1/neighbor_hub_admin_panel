import '../../../../core/utils/result.dart';
import '../entity/polls_entity.dart';

abstract class PollsRepository {
  Future<Result<List<PollsEntity>>> getPollsData();
}
