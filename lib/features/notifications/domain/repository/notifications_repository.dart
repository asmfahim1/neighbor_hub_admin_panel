import '../../../../core/utils/result.dart';
import '../entity/notifications_entity.dart';

abstract class NotificationsRepository {
  Future<Result<List<NotificationsEntity>>> getNotificationsData();
}
