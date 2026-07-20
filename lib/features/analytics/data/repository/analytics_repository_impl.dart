import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/analytics_entity.dart';
import '../../domain/repository/analytics_repository.dart';
// import '../model/analytics_model.dart';
import '../source/analytics_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: AnalyticsRepository)

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteSource _remote;

  @override
  Future<Result<List<AnalyticsEntity>>> getAnalyticsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
