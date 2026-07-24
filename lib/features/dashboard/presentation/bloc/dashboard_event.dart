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

/// Starts the dashboard in UI-preview mode without Firebase listeners.
class DashboardPreviewStarted extends DashboardEvent {
  const DashboardPreviewStarted();
}

/// Internal event emitted when the apartments stream updates.
class DashboardApartmentsUpdated extends DashboardEvent {
  const DashboardApartmentsUpdated(this.apartments);
  final List<ApartmentEntity> apartments;

  @override
  List<Object?> get props => [apartments];
}

/// Internal event emitted when the pending requests stream updates.
class DashboardPendingRequestsUpdated extends DashboardEvent {
  const DashboardPendingRequestsUpdated(this.pendingRequests);
  final List<ApartmentRequestEntity> pendingRequests;

  @override
  List<Object?> get props => [pendingRequests];
}

/// Internal event emitted when the posts stream updates.
class DashboardPostsUpdated extends DashboardEvent {
  const DashboardPostsUpdated(this.posts);
  final List<PostEntity> posts;

  @override
  List<Object?> get props => [posts];
}

/// Internal event emitted when the announcements stream updates.
class DashboardAnnouncementsUpdated extends DashboardEvent {
  const DashboardAnnouncementsUpdated(this.announcements);
  final List<AnnouncementEntity> announcements;

  @override
  List<Object?> get props => [announcements];
}

/// Internal event emitted when any dashboard listener fails.
class DashboardFailed extends DashboardEvent {
  const DashboardFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
