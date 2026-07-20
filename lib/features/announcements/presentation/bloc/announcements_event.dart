import 'package:equatable/equatable.dart';

import '../../domain/entity/announcements_entity.dart';

abstract class AnnouncementsEvent extends Equatable {
  const AnnouncementsEvent();

  @override
  List<Object?> get props => [];
}

class AnnouncementsWatchStarted extends AnnouncementsEvent {
  const AnnouncementsWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the bloc's own stream subscription.
class AnnouncementsChanged extends AnnouncementsEvent {
  const AnnouncementsChanged(this.announcements);
  final List<AnnouncementEntity> announcements;

  @override
  List<Object?> get props => [announcements];
}

/// `createdBy` is the admin's uid — the caller (UI layer, once built)
/// supplies it from `CurrentSession.requireUid()`.
class AnnouncementCreateRequested extends AnnouncementsEvent {
  const AnnouncementCreateRequested({
    required this.buildingId,
    required this.title,
    required this.body,
    required this.createdBy,
  });

  final String buildingId;
  final String title;
  final String body;
  final String createdBy;

  @override
  List<Object?> get props => [buildingId, title, body, createdBy];
}

class AnnouncementUpdateRequested extends AnnouncementsEvent {
  const AnnouncementUpdateRequested(this.announcement);
  final AnnouncementEntity announcement;

  @override
  List<Object?> get props => [announcement];
}

class AnnouncementDeleteRequested extends AnnouncementsEvent {
  const AnnouncementDeleteRequested(this.announcementId);
  final String announcementId;

  @override
  List<Object?> get props => [announcementId];
}
