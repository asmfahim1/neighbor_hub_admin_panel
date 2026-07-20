import '../../../../core/utils/result.dart';
import '../entity/buildings_entity.dart';

abstract class BuildingsRepository {
  /// Realtime listener on `buildings/{buildingId}` — `null` if the document
  /// doesn't exist yet (first-run empty building).
  Stream<BuildingEntity?> watchBuilding(String buildingId);

  Future<Result<BuildingEntity?>> getBuilding(String buildingId);

  /// Create (first save) or update `name`/`address`/`totalFloors`/`apartmentsPerFloor`.
  /// `adminUid` is intentionally not settable here — it only ever changes via
  /// the Residents Transfer-Admin-Role flow (§7.5.4).
  Future<Result<void>> saveBuilding(BuildingEntity building);

  /// Bulk-generates `totalFloors` × `apartmentsPerFloor` `apartments` docs via
  /// chunked `WriteBatch`es, skipping any (floor, number) combination that
  /// already exists. Returns the count of apartments actually created.
  Future<Result<int>> generateApartments({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
  });
}
