import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../../domain/repository/dashboard_repository.dart';
// import '../model/dashboard_model.dart';
import '../source/dashboard_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: DashboardRepository)

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteSource _remote;

  @override
  Future<Result<List<DashboardEntity>>> getDashboardData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
