import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/buildings_entity.dart';
import '../repository/buildings_repository.dart';

@injectable
class WatchBuildingUseCase {
  WatchBuildingUseCase(this._repo);
  final BuildingsRepository _repo;

  Stream<BuildingEntity?> call(String buildingId) => _repo.watchBuilding(buildingId);
}

@injectable
class SaveBuildingUseCase {
  SaveBuildingUseCase(this._repo);
  final BuildingsRepository _repo;

  Future<Result<void>> call(BuildingEntity building) => _repo.saveBuilding(building);
}

@injectable
class GenerateApartmentsUseCase {
  GenerateApartmentsUseCase(this._repo);
  final BuildingsRepository _repo;

  Future<Result<int>> call({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
  }) {
    return _repo.generateApartments(
      buildingId: buildingId,
      totalFloors: totalFloors,
      apartmentsPerFloor: apartmentsPerFloor,
    );
  }
}
