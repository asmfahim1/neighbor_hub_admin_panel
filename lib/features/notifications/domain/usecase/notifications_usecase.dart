import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entity/notifications_entity.dart';
import '../repository/notifications_repository.dart';

@injectable
class WatchNotificationsInboxUseCase {
  WatchNotificationsInboxUseCase(this._repo);
  final NotificationsRepository _repo;

  Stream<List<NotificationEntity>> call(String recipientUid) => _repo.watchInbox(recipientUid);
}

@injectable
class MarkNotificationAsReadUseCase {
  MarkNotificationAsReadUseCase(this._repo);
  final NotificationsRepository _repo;

  Future<Result<void>> call(String notificationId) => _repo.markAsRead(notificationId);
}
