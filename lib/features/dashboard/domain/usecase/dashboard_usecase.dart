import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../repository/dashboard_repository.dart';

@injectable
class WatchDashboardApartmentsUseCase {
  WatchDashboardApartmentsUseCase(this._repo);
  final DashboardRepository _repo;

  Stream<List<ApartmentEntity>> call(String buildingId) => _repo.watchApartments(buildingId);
}

@injectable
class WatchDashboardPendingRequestsUseCase {
  WatchDashboardPendingRequestsUseCase(this._repo);
  final DashboardRepository _repo;

  Stream<List<ApartmentRequestEntity>> call(String buildingId) =>
      _repo.watchPendingRequests(buildingId);
}

@injectable
class WatchDashboardRecentPostsUseCase {
  WatchDashboardRecentPostsUseCase(this._repo);
  final DashboardRepository _repo;

  Stream<List<PostEntity>> call(String buildingId, {int limit = 50}) =>
      _repo.watchRecentPosts(buildingId, limit: limit);
}

@injectable
class WatchDashboardRecentAnnouncementsUseCase {
  WatchDashboardRecentAnnouncementsUseCase(this._repo);
  final DashboardRepository _repo;

  Stream<List<AnnouncementEntity>> call(String buildingId, {int limit = 20}) =>
      _repo.watchRecentAnnouncements(buildingId, limit: limit);
}
