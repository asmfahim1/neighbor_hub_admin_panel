import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/firebase/current_session.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/polls_entity.dart';
import '../../domain/usecase/polls_usecase.dart';
import 'polls_event.dart';
import 'polls_state.dart';

@injectable
class PollsBloc extends Bloc<PollsEvent, PollsState> {
  PollsBloc(
    this._watchPolls,
    this._watchVotes,
    this._createPoll,
    this._closePoll,
    this._session,
  ) : super(const PollsState()) {
    on<PollsWatchStarted>(_onWatchStarted);
    on<PollsChanged>(_onPollsChanged);
    on<PollCreateRequested>(_onCreateRequested);
    on<PollCloseRequested>(_onCloseRequested);
    on<PollVotesWatchStarted>(_onVotesWatchStarted);
    on<PollVotesWatchStopped>(_onVotesWatchStopped);
    on<PollVotesChanged>(_onVotesChanged);
  }

  final WatchPollsUseCase _watchPolls;
  final WatchPollVotesUseCase _watchVotes;
  final CreatePollUseCase _createPoll;
  final ClosePollUseCase _closePoll;
  final CurrentSession _session;

  StreamSubscription<List<PollEntity>>? _pollsSubscription;
  StreamSubscription<List<PollVoteEntity>>? _votesSubscription;

  Future<void> _onWatchStarted(PollsWatchStarted event, Emitter<PollsState> emit) async {
    emit(state.copyWith(status: PollsStatus.loading));
    await _pollsSubscription?.cancel();
    _pollsSubscription = _watchPolls(event.buildingId).listen((polls) {
      add(PollsChanged(polls));
    });
  }

  void _onPollsChanged(PollsChanged event, Emitter<PollsState> emit) {
    emit(state.copyWith(status: PollsStatus.loaded, polls: event.polls));
  }

  Future<void> _onCreateRequested(
    PollCreateRequested event,
    Emitter<PollsState> emit,
  ) async {
    emit(state.copyWith(status: PollsStatus.mutating, clearMessage: true));
    final result = await _createPoll(
      buildingId: event.buildingId,
      question: event.question,
      optionTexts: event.optionTexts,
      createdBy: _session.requireUid(),
      closesAt: event.closesAt,
    );
    _emitMutationResult(result, emit);
  }

  Future<void> _onCloseRequested(
    PollCloseRequested event,
    Emitter<PollsState> emit,
  ) async {
    emit(state.copyWith(status: PollsStatus.mutating, clearMessage: true));
    final result = await _closePoll(event.pollId);
    _emitMutationResult(result, emit);
  }

  Future<void> _onVotesWatchStarted(
    PollVotesWatchStarted event,
    Emitter<PollsState> emit,
  ) async {
    await _votesSubscription?.cancel();
    _votesSubscription = _watchVotes(event.pollId).listen((votes) {
      add(PollVotesChanged(votes));
    });
  }

  Future<void> _onVotesWatchStopped(
    PollVotesWatchStopped event,
    Emitter<PollsState> emit,
  ) async {
    await _votesSubscription?.cancel();
    _votesSubscription = null;
    emit(state.copyWith(openPollVotes: const []));
  }

  void _onVotesChanged(PollVotesChanged event, Emitter<PollsState> emit) {
    emit(state.copyWith(openPollVotes: event.votes));
  }

  /// After any successful mutation, fall back to [PollsStatus.loaded] — the
  /// realtime listener (`PollsChanged`) will follow shortly with the
  /// authoritative list.
  void _emitMutationResult(Result<void> result, Emitter<PollsState> emit) {
    result.fold(
      (failure) => emit(state.copyWith(status: PollsStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: PollsStatus.loaded)),
    );
  }

  @override
  Future<void> close() async {
    await _pollsSubscription?.cancel();
    await _votesSubscription?.cancel();
    return super.close();
  }
}
