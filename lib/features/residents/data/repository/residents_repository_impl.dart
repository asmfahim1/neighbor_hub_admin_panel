import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/residents_entity.dart';
import '../../domain/repository/residents_repository.dart';
// import '../model/residents_model.dart';
import '../source/residents_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: ResidentsRepository)

class ResidentsRepositoryImpl implements ResidentsRepository {
  ResidentsRepositoryImpl(this._remote);

  final ResidentsRemoteSource _remote;

  @override
  Future<Result<List<ResidentsEntity>>> getResidentsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
