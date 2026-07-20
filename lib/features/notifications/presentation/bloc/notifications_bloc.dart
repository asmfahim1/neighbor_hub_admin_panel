import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/models/notification_entity.dart';
import '../../domain/usecase/notifications_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

@injectable
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._watchInbox, this._markAsRead) : super(const NotificationsState()) {
    on<NotificationsWatchStarted>(_onWatchStarted);
    on<NotificationsChanged>(_onChanged);
    on<NotificationMarkAsReadRequested>(_onMarkAsReadRequested);
    on<NotificationsCategoryFilterChanged>(_onCategoryFilterChanged);
  }

  final WatchNotificationsInboxUseCase _watchInbox;
  final MarkNotificationAsReadUseCase _markAsRead;

  StreamSubscription<List<NotificationEntity>>? _subscription;

  Future<void> _onWatchStarted(
    NotificationsWatchStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchInbox(event.recipientUid).listen(
      (notifications) => add(NotificationsChanged(notifications)),
    );
  }

  void _onChanged(NotificationsChanged event, Emitter<NotificationsState> emit) {
    emit(state.copyWith(status: NotificationsStatus.loaded, notifications: event.notifications));
  }

  Future<void> _onMarkAsReadRequested(
    NotificationMarkAsReadRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _markAsRead(event.notificationId);
    result.fold(
      (failure) => emit(state.copyWith(status: NotificationsStatus.failure, message: failure.displayMessage)),
      // The realtime listener will follow shortly with the authoritative
      // (now-read) document; no optimistic local state change needed.
      (_) {},
    );
  }

  void _onCategoryFilterChanged(
    NotificationsCategoryFilterChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(
      categoryFilter: event.category,
      clearCategoryFilter: event.category == null,
    ));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
