import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/buildings_entity.dart';
import '../../domain/repository/buildings_repository.dart';
// import '../model/buildings_model.dart';
import '../source/buildings_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: BuildingsRepository)

class BuildingsRepositoryImpl implements BuildingsRepository {
  BuildingsRepositoryImpl(this._remote);

  final BuildingsRemoteSource _remote;

  @override
  Future<Result<List<BuildingsEntity>>> getBuildingsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
