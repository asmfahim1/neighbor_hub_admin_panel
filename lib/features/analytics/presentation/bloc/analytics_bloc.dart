import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../domain/entity/analytics_entity.dart';
import '../../domain/usecase/analytics_usecase.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

/// Combines three independent realtime listeners into one [AnalyticsEntity]
/// snapshot, recomputed on every emission from any of them — the pragmatic
/// alternative to `rxdart`'s `combineLatest` at this project's scale (§7.9).
/// Mirrors `DashboardBloc`'s shape exactly.
@injectable
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc(
    this._watchApartments,
    this._watchPosts,
    this._watchPolls,
  ) : super(const AnalyticsState()) {
    on<AnalyticsWatchStarted>(_onWatchStarted);
    on<AnalyticsApartmentsUpdated>(_onApartmentsUpdated);
    on<AnalyticsPostsUpdated>(_onPostsUpdated);
    on<AnalyticsPollsUpdated>(_onPollsUpdated);
    on<AnalyticsFailed>(_onFailed);
  }

  final WatchAnalyticsApartmentsUseCase _watchApartments;
  final WatchAnalyticsPostsUseCase _watchPosts;
  final WatchAnalyticsPollsUseCase _watchPolls;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  List<ApartmentEntity> _apartments = const [];
  List<PostEntity> _posts = const [];
  List<PollEntity> _polls = const [];

  Future<void> _onWatchStarted(
    AnalyticsWatchStarted event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsStatus.loading));
    await _cancelSubscriptions();

    _subscriptions.addAll([
      _watchApartments(event.buildingId).listen(
        (apartments) => add(AnalyticsApartmentsUpdated(apartments)),
        onError: (Object e) => add(AnalyticsFailed(e.toString())),
      ),
      _watchPosts(event.buildingId).listen(
        (posts) => add(AnalyticsPostsUpdated(posts)),
        onError: (Object e) => add(AnalyticsFailed(e.toString())),
      ),
      _watchPolls(event.buildingId).listen(
        (polls) => add(AnalyticsPollsUpdated(polls)),
        onError: (Object e) => add(AnalyticsFailed(e.toString())),
      ),
    ]);
  }

  void _onApartmentsUpdated(AnalyticsApartmentsUpdated event, Emitter<AnalyticsState> emit) {
    _apartments = event.apartments;
    _recompute(emit);
  }

  void _onPostsUpdated(AnalyticsPostsUpdated event, Emitter<AnalyticsState> emit) {
    _posts = event.posts;
    _recompute(emit);
  }

  void _onPollsUpdated(AnalyticsPollsUpdated event, Emitter<AnalyticsState> emit) {
    _polls = event.polls;
    _recompute(emit);
  }

  void _recompute(Emitter<AnalyticsState> emit) {
    final snapshot = AnalyticsEntity.compute(
      apartments: _apartments,
      posts: _posts,
      polls: _polls,
    );
    emit(state.copyWith(status: AnalyticsStatus.loaded, analytics: snapshot));
  }

  void _onFailed(AnalyticsFailed event, Emitter<AnalyticsState> emit) {
    emit(state.copyWith(status: AnalyticsStatus.failure, message: event.message));
  }

  Future<void> _cancelSubscriptions() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
