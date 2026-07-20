import '../../../../core/utils/result.dart';
import '../entity/notifications_entity.dart';
import '../repository/notifications_repository.dart';
import 'package:injectable/injectable.dart';


@injectable

class NotificationsUseCase {
  NotificationsUseCase(this._repo);

  final NotificationsRepository _repo;

  Future<Result<List<NotificationsEntity>>> call() {
    return _repo.getNotificationsData();
  }
}
