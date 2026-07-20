import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entity/buildings_entity.dart';
import '../../domain/usecase/buildings_usecase.dart';
import 'buildings_event.dart';
import 'buildings_state.dart';

@injectable
class BuildingsBloc extends Bloc<BuildingsEvent, BuildingsState> {
  BuildingsBloc(
    this._watchBuilding,
    this._saveBuilding,
    this._generateApartments,
  ) : super(const BuildingsState()) {
    on<BuildingWatchStarted>(_onWatchStarted);
    on<BuildingChanged>(_onBuildingChanged);
    on<BuildingSaveRequested>(_onSaveRequested);
    on<ApartmentsGenerationRequested>(_onGenerationRequested);
  }

  final WatchBuildingUseCase _watchBuilding;
  final SaveBuildingUseCase _saveBuilding;
  final GenerateApartmentsUseCase _generateApartments;

  StreamSubscription<BuildingEntity?>? _buildingSubscription;

  Future<void> _onWatchStarted(
    BuildingWatchStarted event,
    Emitter<BuildingsState> emit,
  ) async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    await _buildingSubscription?.cancel();
    _buildingSubscription = _watchBuilding(event.buildingId).listen((building) {
      add(BuildingChanged(building));
    });
  }

  void _onBuildingChanged(BuildingChanged event, Emitter<BuildingsState> emit) {
    emit(state.copyWith(
      status: BuildingsStatus.loaded,
      building: event.building,
      clearBuilding: event.building == null,
    ));
  }

  Future<void> _onSaveRequested(
    BuildingSaveRequested event,
    Emitter<BuildingsState> emit,
  ) async {
    emit(state.copyWith(status: BuildingsStatus.saving, clearMessage: true));
    final result = await _saveBuilding(event.building);
    result.fold(
      (failure) => emit(state.copyWith(status: BuildingsStatus.failure, message: failure.displayMessage)),
      // The realtime listener will push BuildingChanged with the saved data;
      // optimistically reflect it immediately too.
      (_) => emit(state.copyWith(status: BuildingsStatus.loaded, building: event.building)),
    );
  }

  Future<void> _onGenerationRequested(
    ApartmentsGenerationRequested event,
    Emitter<BuildingsState> emit,
  ) async {
    emit(state.copyWith(status: BuildingsStatus.generating, clearMessage: true));
    final result = await _generateApartments(
      buildingId: event.buildingId,
      totalFloors: event.totalFloors,
      apartmentsPerFloor: event.apartmentsPerFloor,
    );
    result.fold(
      (failure) => emit(state.copyWith(status: BuildingsStatus.failure, message: failure.displayMessage)),
      (count) => emit(state.copyWith(status: BuildingsStatus.loaded, lastGeneratedCount: count)),
    );
  }

  @override
  Future<void> close() {
    _buildingSubscription?.cancel();
    return super.close();
  }
}
