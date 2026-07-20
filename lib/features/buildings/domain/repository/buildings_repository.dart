import '../../../../core/utils/result.dart';
import '../entity/buildings_entity.dart';

abstract class BuildingsRepository {
  Future<Result<List<BuildingsEntity>>> getBuildingsData();
}
