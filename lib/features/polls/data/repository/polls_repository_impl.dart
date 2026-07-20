import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/poll_status.dart';
import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/polls_entity.dart';
import '../../domain/repository/polls_repository.dart';
import '../source/polls_remote_source.dart';

@LazySingleton(as: PollsRepository)
class PollsRepositoryImpl implements PollsRepository {
  PollsRepositoryImpl(this._remote);

  final PollsRemoteSource _remote;

  @override
  Stream<List<PollEntity>> watchPolls(String buildingId) => _remote.watchPolls(buildingId);

  @override
  Stream<List<PollVoteEntity>> watchVotes(String pollId) => _remote.watchVotes(pollId);

  @override
  Future<Result<void>> createPoll({
    required String buildingId,
    required String question,
    required List<String> optionTexts,
    required String createdBy,
    DateTime? closesAt,
  }) async {
    if (optionTexts.length < 2) {
      return const Left(ValidationFailure('A poll needs at least two options.'));
    }
    try {
      final options = [
        for (var i = 0; i < optionTexts.length; i++)
          PollOptionEntity(id: 'opt_${i + 1}', text: optionTexts[i], voteCount: 0),
      ];
      final poll = PollEntity(
        id: '', // ignored by the remote source on create (auto-generated doc ID)
        buildingId: buildingId,
        question: question,
        options: options,
        status: PollStatus.active,
        createdBy: createdBy,
        createdAt: DateTime.now(),
        closesAt: closesAt,
      );
      await _remote.createPoll(poll);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> closePoll(String pollId) async {
    try {
      await _remote.closePoll(pollId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
