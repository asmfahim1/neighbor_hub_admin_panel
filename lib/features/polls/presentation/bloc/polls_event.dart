import 'package:equatable/equatable.dart';

import '../../domain/entity/polls_entity.dart';

abstract class PollsEvent extends Equatable {
  const PollsEvent();

  @override
  List<Object?> get props => [];
}

class PollsWatchStarted extends PollsEvent {
  const PollsWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the bloc's own poll-list stream subscription.
class PollsChanged extends PollsEvent {
  const PollsChanged(this.polls);
  final List<PollEntity> polls;

  @override
  List<Object?> get props => [polls];
}

class PollCreateRequested extends PollsEvent {
  const PollCreateRequested({
    required this.buildingId,
    required this.question,
    required this.optionTexts,
    this.closesAt,
  });

  final String buildingId;
  final String question;
  final List<String> optionTexts;
  final DateTime? closesAt;

  @override
  List<Object?> get props => [buildingId, question, optionTexts, closesAt];
}

class PollCloseRequested extends PollsEvent {
  const PollCloseRequested(this.pollId);
  final String pollId;

  @override
  List<Object?> get props => [pollId];
}

/// Starts the `polls/{pollId}/votes` listener for a single opened poll
/// (participation counting) — independent of the main poll-list stream.
class PollVotesWatchStarted extends PollsEvent {
  const PollVotesWatchStarted(this.pollId);
  final String pollId;

  @override
  List<Object?> get props => [pollId];
}

class PollVotesWatchStopped extends PollsEvent {
  const PollVotesWatchStopped();
}

/// Internal — emitted by the bloc's own votes stream subscription.
class PollVotesChanged extends PollsEvent {
  const PollVotesChanged(this.votes);
  final List<PollVoteEntity> votes;

  @override
  List<Object?> get props => [votes];
}
