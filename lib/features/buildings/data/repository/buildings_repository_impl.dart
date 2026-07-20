import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/buildings_entity.dart';
import '../../domain/repository/buildings_repository.dart';
import '../source/buildings_remote_source.dart';

@LazySingleton(as: BuildingsRepository)
class BuildingsRepositoryImpl implements BuildingsRepository {
  BuildingsRepositoryImpl(this._remote);

  final BuildingsRemoteSource _remote;

  @override
  Stream<BuildingEntity?> watchBuilding(String buildingId) =>
      _remote.watchBuilding(buildingId);

  @override
  Future<Result<BuildingEntity?>> getBuilding(String buildingId) async {
    try {
      return Right(await _remote.fetchBuilding(buildingId));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> saveBuilding(BuildingEntity building) async {
    try {
      await _remote.saveBuilding(building);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<int>> generateApartments({
    required String buildingId,
    required int totalFloors,
    required int apartmentsPerFloor,
  }) async {
    try {
      final created = await _remote.generateApartments(
        buildingId: buildingId,
        totalFloors: totalFloors,
        apartmentsPerFloor: apartmentsPerFloor,
      );
      return Right(created);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
