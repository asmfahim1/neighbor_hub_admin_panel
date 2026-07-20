import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/polls_entity.dart';
import '../repository/polls_repository.dart';

@injectable
class WatchPollsUseCase {
  WatchPollsUseCase(this._repo);
  final PollsRepository _repo;

  Stream<List<PollEntity>> call(String buildingId) => _repo.watchPolls(buildingId);
}

@injectable
class WatchPollVotesUseCase {
  WatchPollVotesUseCase(this._repo);
  final PollsRepository _repo;

  Stream<List<PollVoteEntity>> call(String pollId) => _repo.watchVotes(pollId);
}

@injectable
class CreatePollUseCase {
  CreatePollUseCase(this._repo);
  final PollsRepository _repo;

  Future<Result<void>> call({
    required String buildingId,
    required String question,
    required List<String> optionTexts,
    required String createdBy,
    DateTime? closesAt,
  }) {
    return _repo.createPoll(
      buildingId: buildingId,
      question: question,
      optionTexts: optionTexts,
      createdBy: createdBy,
      closesAt: closesAt,
    );
  }
}

@injectable
class ClosePollUseCase {
  ClosePollUseCase(this._repo);
  final PollsRepository _repo;

  Future<Result<void>> call(String pollId) => _repo.closePoll(pollId);
}
