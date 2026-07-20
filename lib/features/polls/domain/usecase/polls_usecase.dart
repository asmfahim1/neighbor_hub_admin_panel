import '../../../../core/utils/result.dart';
import '../entity/polls_entity.dart';
import '../repository/polls_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class PollsUseCase {
  PollsUseCase(this._repo);

  final PollsRepository _repo;

  Future<Result<List<PollsEntity>>> call() {
    return _repo.getPollsData();
  }
}
