import 'package:equatable/equatable.dart';

import '../../domain/entity/buildings_entity.dart';

abstract class BuildingsEvent extends Equatable {
  const BuildingsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once to start the realtime `buildings/{buildingId}` listener.
class BuildingWatchStarted extends BuildingsEvent {
  const BuildingWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the bloc's own stream subscription.
class BuildingChanged extends BuildingsEvent {
  const BuildingChanged(this.building);
  final BuildingEntity? building;

  @override
  List<Object?> get props => [building];
}

class BuildingSaveRequested extends BuildingsEvent {
  const BuildingSaveRequested(this.building);
  final BuildingEntity building;

  @override
  List<Object?> get props => [building];
}

/// Bulk apartment generation (Web only per §7.3) for the current building.
class ApartmentsGenerationRequested extends BuildingsEvent {
  const ApartmentsGenerationRequested({
    required this.buildingId,
    required this.totalFloors,
    required this.apartmentsPerFloor,
  });

  final String buildingId;
  final int totalFloors;
  final int apartmentsPerFloor;

  @override
  List<Object?> get props => [buildingId, totalFloors, apartmentsPerFloor];
}
