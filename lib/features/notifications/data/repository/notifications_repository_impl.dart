import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/notifications_entity.dart';
import '../../domain/repository/notifications_repository.dart';
import '../source/notifications_remote_source.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteSource _remote;

  @override
  Stream<List<NotificationEntity>> watchInbox(String recipientUid) =>
      _remote.watchInbox(recipientUid);

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      await _remote.markAsRead(notificationId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
