import 'package:equatable/equatable.dart';
import '../../domain/entity/notifications_entity.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.items = const [],
    this.message,
  });

  final NotificationsStatus status;
  final List<NotificationsEntity> items;
  final String? message;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationsEntity>? items,
    String? message,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
