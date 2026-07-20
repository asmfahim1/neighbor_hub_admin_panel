import 'package:equatable/equatable.dart';

import '../../domain/entity/buildings_entity.dart';

enum BuildingsStatus { initial, loading, loaded, saving, generating, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.building,
    this.message,
    this.lastGeneratedCount,
  });

  final BuildingsStatus status;
  final BuildingEntity? building;
  final String? message;

  /// Set after a successful [ApartmentsGenerationRequested] — how many new
  /// apartments were actually created (post-dedupe).
  final int? lastGeneratedCount;

  BuildingsState copyWith({
    BuildingsStatus? status,
    BuildingEntity? building,
    bool clearBuilding = false,
    String? message,
    bool clearMessage = false,
    int? lastGeneratedCount,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      building: clearBuilding ? null : (building ?? this.building),
      message: clearMessage ? null : (message ?? this.message),
      lastGeneratedCount: lastGeneratedCount ?? this.lastGeneratedCount,
    );
  }

  @override
  List<Object?> get props => [status, building, message, lastGeneratedCount];
}
