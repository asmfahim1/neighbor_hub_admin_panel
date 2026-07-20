import '../../../../core/utils/result.dart';
import '../entity/buildings_entity.dart';
import '../repository/buildings_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class BuildingsUseCase {
  BuildingsUseCase(this._repo);

  final BuildingsRepository _repo;

  Future<Result<List<BuildingsEntity>>> call() {
    return _repo.getBuildingsData();
  }
}
