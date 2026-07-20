import 'package:equatable/equatable.dart';

import '../../../../core/models/models.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once to start all four realtime listeners for [buildingId].
class DashboardWatchStarted extends DashboardEvent {
  const DashboardWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — one per underlying stream, each triggers a full recompute via
/// `DashboardEntity.compute` using the latest snapshot of all four lists.
class DashboardApartmentsUpdated extends DashboardEvent {
  const DashboardApartmentsUpdated(this.apartments);
  final List<ApartmentEntity> apartments;

  @override
  List<Object?> get props => [apartments];
}

class DashboardPendingRequestsUpdated extends DashboardEvent {
  const DashboardPendingRequestsUpdated(this.pendingRequests);
  final List<ApartmentRequestEntity> pendingRequests;

  @override
  List<Object?> get props => [pendingRequests];
}

class DashboardPostsUpdated extends DashboardEvent {
  const DashboardPostsUpdated(this.posts);
  final List<PostEntity> posts;

  @override
  List<Object?> get props => [posts];
}

class DashboardAnnouncementsUpdated extends DashboardEvent {
  const DashboardAnnouncementsUpdated(this.announcements);
  final List<AnnouncementEntity> announcements;

  @override
  List<Object?> get props => [announcements];
}

/// Internal — any one of the four listeners errored (e.g. dropped
/// connection, permission change). Non-fatal to the other three feeds.
class DashboardFailed extends DashboardEvent {
  const DashboardFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
