import 'package:equatable/equatable.dart';

import '../../../../core/models/models.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once to start all three realtime listeners for [buildingId].
class AnalyticsWatchStarted extends AnalyticsEvent {
  const AnalyticsWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — one per underlying stream, each triggers a full recompute via
/// `AnalyticsEntity.compute` using the latest snapshot of all three lists.
class AnalyticsApartmentsUpdated extends AnalyticsEvent {
  const AnalyticsApartmentsUpdated(this.apartments);
  final List<ApartmentEntity> apartments;

  @override
  List<Object?> get props => [apartments];
}

class AnalyticsPostsUpdated extends AnalyticsEvent {
  const AnalyticsPostsUpdated(this.posts);
  final List<PostEntity> posts;

  @override
  List<Object?> get props => [posts];
}

class AnalyticsPollsUpdated extends AnalyticsEvent {
  const AnalyticsPollsUpdated(this.polls);
  final List<PollEntity> polls;

  @override
  List<Object?> get props => [polls];
}

/// Internal — any one of the three listeners errored. Non-fatal to the
/// other two feeds.
class AnalyticsFailed extends AnalyticsEvent {
  const AnalyticsFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
