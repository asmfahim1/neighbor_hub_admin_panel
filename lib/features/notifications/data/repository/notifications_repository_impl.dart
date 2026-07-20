import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/notifications_entity.dart';
import '../../domain/repository/notifications_repository.dart';
// import '../model/notifications_model.dart';
import '../source/notifications_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: NotificationsRepository)

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteSource _remote;

  @override
  Future<Result<List<NotificationsEntity>>> getNotificationsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
