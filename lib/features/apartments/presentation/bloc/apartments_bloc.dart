import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entity/apartments_entity.dart';
import '../../domain/usecase/apartments_usecase.dart';
import 'apartments_event.dart';
import 'apartments_state.dart';

@injectable
class ApartmentsBloc extends Bloc<ApartmentsEvent, ApartmentsState> {
  ApartmentsBloc(
    this._watchApartments,
    this._createApartment,
    this._updateApartment,
    this._deleteApartment,
    this._setStatus,
  ) : super(const ApartmentsState()) {
    on<ApartmentsWatchStarted>(_onWatchStarted);
    on<ApartmentsChanged>(_onChanged);
    on<ApartmentCreateRequested>(_onCreateRequested);
    on<ApartmentUpdateRequested>(_onUpdateRequested);
    on<ApartmentDeleteRequested>(_onDeleteRequested);
    on<ApartmentStatusChangeRequested>(_onStatusChangeRequested);
  }

  final WatchApartmentsUseCase _watchApartments;
  final CreateApartmentUseCase _createApartment;
  final UpdateApartmentUseCase _updateApartment;
  final DeleteApartmentUseCase _deleteApartment;
  final SetApartmentStatusUseCase _setStatus;

  StreamSubscription<List<ApartmentEntity>>? _subscription;

  Future<void> _onWatchStarted(
    ApartmentsWatchStarted event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.loading));
    await _subscription?.cancel();
    _subscription = _watchApartments(event.buildingId).listen((apartments) {
      add(ApartmentsChanged(apartments));
    });
  }

  void _onChanged(ApartmentsChanged event, Emitter<ApartmentsState> emit) {
    emit(state.copyWith(status: ApartmentsStatus.loaded, apartments: event.apartments));
  }

  Future<void> _onCreateRequested(
    ApartmentCreateRequested event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.mutating, clearMessage: true));
    final result = await _createApartment(event.apartment);
    _emitMutationResult(result, emit);
  }

  Future<void> _onUpdateRequested(
    ApartmentUpdateRequested event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.mutating, clearMessage: true));
    final result = await _updateApartment(event.apartment);
    _emitMutationResult(result, emit);
  }

  Future<void> _onDeleteRequested(
    ApartmentDeleteRequested event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.mutating, clearMessage: true));
    final result = await _deleteApartment(event.apartmentId);
    _emitMutationResult(result, emit);
  }

  Future<void> _onStatusChangeRequested(
    ApartmentStatusChangeRequested event,
    Emitter<ApartmentsState> emit,
  ) async {
    emit(state.copyWith(status: ApartmentsStatus.mutating, clearMessage: true));
    final result = await _setStatus(event.apartmentId, event.status);
    _emitMutationResult(result, emit);
  }

  /// After any successful mutation, fall back to [ApartmentsStatus.loaded] —
  /// the realtime listener (`ApartmentsChanged`) will follow shortly with the
  /// authoritative list.
  void _emitMutationResult(Result<void> result, Emitter<ApartmentsState> emit) {
    result.fold(
      (failure) => emit(state.copyWith(status: ApartmentsStatus.failure, message: failure.displayMessage)),
      (_) => emit(state.copyWith(status: ApartmentsStatus.loaded)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
