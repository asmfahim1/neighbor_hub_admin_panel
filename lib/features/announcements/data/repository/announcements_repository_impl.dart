import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/announcements_entity.dart';
import '../../domain/repository/announcements_repository.dart';
// import '../model/announcements_model.dart';
import '../source/announcements_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: AnnouncementsRepository)

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl(this._remote);

  final AnnouncementsRemoteSource _remote;

  @override
  Future<Result<List<AnnouncementsEntity>>> getAnnouncementsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
