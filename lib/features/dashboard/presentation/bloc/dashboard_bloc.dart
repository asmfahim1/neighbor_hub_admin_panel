import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/usecase/dashboard_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Combines four independent realtime listeners into one [DashboardEntity]
/// snapshot, recomputed on every emission from any of them — the pragmatic
/// alternative to `rxdart`'s `combineLatest` at this project's scale (§7.9).
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(
    this._watchApartments,
    this._watchPendingRequests,
    this._watchRecentPosts,
    this._watchRecentAnnouncements,
  ) : super(const DashboardState()) {
    on<DashboardWatchStarted>(_onWatchStarted);
    on<DashboardApartmentsUpdated>(_onApartmentsUpdated);
    on<DashboardPendingRequestsUpdated>(_onPendingRequestsUpdated);
    on<DashboardPostsUpdated>(_onPostsUpdated);
    on<DashboardAnnouncementsUpdated>(_onAnnouncementsUpdated);
    on<DashboardFailed>(_onFailed);
  }

  final WatchDashboardApartmentsUseCase _watchApartments;
  final WatchDashboardPendingRequestsUseCase _watchPendingRequests;
  final WatchDashboardRecentPostsUseCase _watchRecentPosts;
  final WatchDashboardRecentAnnouncementsUseCase _watchRecentAnnouncements;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  List<ApartmentEntity> _apartments = const [];
  List<ApartmentRequestEntity> _pendingRequests = const [];
  List<PostEntity> _posts = const [];
  List<AnnouncementEntity> _announcements = const [];

  Future<void> _onWatchStarted(
    DashboardWatchStarted event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    await _cancelSubscriptions();

    _subscriptions.addAll([
      _watchApartments(event.buildingId).listen(
        (apartments) => add(DashboardApartmentsUpdated(apartments)),
        onError: (Object e) => add(DashboardFailed(e.toString())),
      ),
      _watchPendingRequests(event.buildingId).listen(
        (requests) => add(DashboardPendingRequestsUpdated(requests)),
        onError: (Object e) => add(DashboardFailed(e.toString())),
      ),
      _watchRecentPosts(event.buildingId).listen(
        (posts) => add(DashboardPostsUpdated(posts)),
        onError: (Object e) => add(DashboardFailed(e.toString())),
      ),
      _watchRecentAnnouncements(event.buildingId).listen(
        (announcements) => add(DashboardAnnouncementsUpdated(announcements)),
        onError: (Object e) => add(DashboardFailed(e.toString())),
      ),
    ]);
  }

  void _onApartmentsUpdated(DashboardApartmentsUpdated event, Emitter<DashboardState> emit) {
    _apartments = event.apartments;
    _recompute(emit);
  }

  void _onPendingRequestsUpdated(
    DashboardPendingRequestsUpdated event,
    Emitter<DashboardState> emit,
  ) {
    _pendingRequests = event.pendingRequests;
    _recompute(emit);
  }

  void _onPostsUpdated(DashboardPostsUpdated event, Emitter<DashboardState> emit) {
    _posts = event.posts;
    _recompute(emit);
  }

  void _onAnnouncementsUpdated(
    DashboardAnnouncementsUpdated event,
    Emitter<DashboardState> emit,
  ) {
    _announcements = event.announcements;
    _recompute(emit);
  }

  void _recompute(Emitter<DashboardState> emit) {
    final snapshot = DashboardEntity.compute(
      apartments: _apartments,
      pendingRequests: _pendingRequests,
      posts: _posts,
      announcements: _announcements,
    );
    emit(state.copyWith(status: DashboardStatus.loaded, dashboard: snapshot));
  }

  void _onFailed(DashboardFailed event, Emitter<DashboardState> emit) {
    emit(state.copyWith(status: DashboardStatus.failure, message: event.message));
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
