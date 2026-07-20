import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/announcements_usecase.dart';
import 'announcements_event.dart';
import 'announcements_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  AnnouncementsBloc(this._useCase) : super(const AnnouncementsState()) {
    on<LoadAnnouncements>(_onLoad);
    add(const LoadAnnouncements());
  }

  final AnnouncementsUseCase _useCase;

  Future<void> _onLoad(
    LoadAnnouncements event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementsStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnnouncementsStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AnnouncementsStatus.success,
          items: data,
        ),
      ),
    );
  }
}
