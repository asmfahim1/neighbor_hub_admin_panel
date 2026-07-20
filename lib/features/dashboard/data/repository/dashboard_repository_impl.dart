import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../source/dashboard_remote_source.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteSource _remote;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) =>
      _remote.watchApartments(buildingId);

  @override
  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId) =>
      _remote.watchPendingRequests(buildingId);

  @override
  Stream<List<PostEntity>> watchRecentPosts(String buildingId, {int limit = 50}) =>
      _remote.watchRecentPosts(buildingId, limit: limit);

  @override
  Stream<List<AnnouncementEntity>> watchRecentAnnouncements(String buildingId, {int limit = 20}) =>
      _remote.watchRecentAnnouncements(buildingId, limit: limit);
}
