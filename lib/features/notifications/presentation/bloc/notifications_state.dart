import 'package:equatable/equatable.dart';

import '../../../../core/constants/notification_category.dart';
import '../../domain/entity/notifications_entity.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.categoryFilter,
    this.message,
  });

  final NotificationsStatus status;
  final List<NotificationEntity> notifications;

  /// `null` means "all categories".
  final NotificationCategory? categoryFilter;
  final String? message;

  /// The list after applying [categoryFilter] — this is what the UI renders.
  List<NotificationEntity> get visibleNotifications {
    final filter = categoryFilter;
    if (filter == null) return notifications;
    return notifications.where((n) => n.category == filter).toList();
  }

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    NotificationCategory? categoryFilter,
    bool clearCategoryFilter = false,
    String? message,
    bool clearMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      categoryFilter: clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, notifications, categoryFilter, message];
}
