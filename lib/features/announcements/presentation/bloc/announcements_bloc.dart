import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entity/announcements_entity.dart';
import '../../domain/usecase/announcements_usecase.dart';
import 'announcements_event.dart';
import 'announcements_state.dart';

@injectable
class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  AnnouncementsBloc(
    this._watchAnnouncements,
    this._createAnnouncement,
    this._updateAnnouncement,
    this._deleteAnnouncement,
  ) : super(const AnnouncementsState()) {
    on<AnnouncementsWatchStarted>(_onWatchStarted);
    on<AnnouncementsChanged>(_onChanged);
    on<AnnouncementCreateRequested>(_onCreateRequested);
    on<AnnouncementUpdateRequested>(_onUpdateRequested);
    on<AnnouncementDeleteRequested>(_onDeleteRequested);
  }

  final WatchAnnouncementsUseCase _watchAnnouncements;
  final CreateAnnouncementUseCase _createAnnouncement;
  final UpdateAnnouncementUseCase _updateAnnouncement;
  final DeleteAnnouncementUseCase _deleteAnnouncement;

  StreamSubscription<List<AnnouncementEntity>>? _subscription;

  Future<void> _onWatchStarted(
    AnnouncementsWatchStarted event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchAnnouncements(event.buildingId).listen((announcements) {
      add(AnnouncementsChanged(announcements));
    });
  }

  void _onChanged(AnnouncementsChanged event, Emitter<AnnouncementsState> emit) {
    emit(state.copyWith(status: AnnouncementsStatus.loaded, announcements: event.announcements));
  }

  Future<void> _onCreateRequested(
    AnnouncementCreateRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementsStatus.mutating, clearMessage: true));
    final result = await _createAnnouncement(
      buildingId: event.buildingId,
      title: event.title,
      body: event.body,
      createdBy: event.createdBy,
    );
    _emitMutationResult(result, emit);
  }

  Future<void> _onUpdateRequested(
    AnnouncementUpdateRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementsStatus.mutating, clearMessage: true));
    final result = await _updateAnnouncement(event.announcement);
    _emitMutationResult(result, emit);
  }

  Future<void> _onDeleteRequested(
    AnnouncementDeleteRequested event,
    Emitter<AnnouncementsState> emit,
  ) async {
    emit(state.copyWith(status: AnnouncementsStatus.mutating, clearMessage: true));
    final result = await _deleteAnnouncement(event.announcementId);
    _emitMutationResult(result, emit);
  }

  /// After any successful mutation, fall back to [AnnouncementsStatus.loaded]
  /// — the realtime listener (`AnnouncementsChanged`) follows shortly with
  /// the authoritative list.
  void _emitMutationResult(Result<void> result, Emitter<AnnouncementsState> emit) {
    result.fold(
      (failure) =>
          emit(state.copyWith(status: AnnouncementsStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: AnnouncementsStatus.loaded)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
