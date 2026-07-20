import '../../../../core/utils/result.dart';
import '../entity/polls_entity.dart';

abstract class PollsRepository {
  /// Realtime listener on `polls where buildingId == X`, newest first.
  Stream<List<PollEntity>> watchPolls(String buildingId);

  /// Realtime listener on `polls/{pollId}/votes` — for participation counting
  /// on a single opened poll, not folded into [watchPolls].
  Stream<List<PollVoteEntity>> watchVotes(String pollId);

  /// Creates a single-choice poll. Option IDs are generated sequentially
  /// (`opt_1`, `opt_2`, ...) from [optionTexts]; each starts at `voteCount: 0`.
  /// Requires at least two options.
  Future<Result<void>> createPoll({
    required String buildingId,
    required String question,
    required List<String> optionTexts,
    required String createdBy,
    DateTime? closesAt,
  });

  /// Manual close — the only status write this feature performs. There is no
  /// automatic/server-side close; clients check `PollEntity.isExpired` at
  /// render time instead (§7.8, no Cloud Function/cron in Phase 1).
  Future<Result<void>> closePoll(String pollId);
}
