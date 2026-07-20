import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/notifications_usecase.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc(this._useCase) : super(const NotificationsState()) {
    on<LoadNotifications>(_onLoad);
    add(const LoadNotifications());
  }

  final NotificationsUseCase _useCase;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
