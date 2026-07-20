import 'package:equatable/equatable.dart';

import '../../domain/entity/polls_entity.dart';

enum PollsStatus { initial, loading, loaded, mutating, failure }

class PollsState extends Equatable {
  const PollsState({
    this.status = PollsStatus.initial,
    this.polls = const [],
    this.openPollVotes = const [],
    this.message,
  });

  final PollsStatus status;
  final List<PollEntity> polls;

  /// Votes for whichever poll currently has [PollVotesWatchStarted] active;
  /// empty when no poll's results are open.
  final List<PollVoteEntity> openPollVotes;

  final String? message;

  PollsState copyWith({
    PollsStatus? status,
    List<PollEntity>? polls,
    List<PollVoteEntity>? openPollVotes,
    String? message,
    bool clearMessage = false,
  }) {
    return PollsState(
      status: status ?? this.status,
      polls: polls ?? this.polls,
      openPollVotes: openPollVotes ?? this.openPollVotes,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, polls, openPollVotes, message];
}
