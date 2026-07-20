import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/moderation_entity.dart';
import '../../domain/repository/moderation_repository.dart';
// import '../model/moderation_model.dart';
import '../source/moderation_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: ModerationRepository)

class ModerationRepositoryImpl implements ModerationRepository {
  ModerationRepositoryImpl(this._remote);

  final ModerationRemoteSource _remote;

  @override
  Future<Result<List<ModerationEntity>>> getModerationData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
