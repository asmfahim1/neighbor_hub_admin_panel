import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/polls_entity.dart';
import '../../domain/repository/polls_repository.dart';
// import '../model/polls_model.dart';
import '../source/polls_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: PollsRepository)

class PollsRepositoryImpl implements PollsRepository {
  PollsRepositoryImpl(this._remote);

  final PollsRemoteSource _remote;

  @override
  Future<Result<List<PollsEntity>>> getPollsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
