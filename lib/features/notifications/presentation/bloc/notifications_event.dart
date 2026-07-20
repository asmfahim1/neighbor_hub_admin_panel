import 'package:equatable/equatable.dart';

import '../../../../core/constants/notification_category.dart';
import '../../domain/entity/notifications_entity.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsWatchStarted extends NotificationsEvent {
  const NotificationsWatchStarted(this.recipientUid);
  final String recipientUid;

  @override
  List<Object?> get props => [recipientUid];
}

/// Internal — emitted by the bloc's own stream subscription.
class NotificationsChanged extends NotificationsEvent {
  const NotificationsChanged(this.notifications);
  final List<NotificationEntity> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationMarkAsReadRequested extends NotificationsEvent {
  const NotificationMarkAsReadRequested(this.notificationId);
  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

/// Client-side category filter — `null` means "all categories". Filtering
/// happens over the already-fetched list, not as a second Firestore query
/// (see `notifications_repository.dart`).
class NotificationsCategoryFilterChanged extends NotificationsEvent {
  const NotificationsCategoryFilterChanged(this.category);
  final NotificationCategory? category;

  @override
  List<Object?> get props => [category];
}
