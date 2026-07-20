import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../repository/analytics_repository.dart';

@injectable
class WatchAnalyticsApartmentsUseCase {
  WatchAnalyticsApartmentsUseCase(this._repo);
  final AnalyticsRepository _repo;

  Stream<List<ApartmentEntity>> call(String buildingId) => _repo.watchApartments(buildingId);
}

@injectable
class WatchAnalyticsPostsUseCase {
  WatchAnalyticsPostsUseCase(this._repo);
  final AnalyticsRepository _repo;

  Stream<List<PostEntity>> call(String buildingId, {int limit = 500}) =>
      _repo.watchPosts(buildingId, limit: limit);
}

@injectable
class WatchAnalyticsPollsUseCase {
  WatchAnalyticsPollsUseCase(this._repo);
  final AnalyticsRepository _repo;

  Stream<List<PollEntity>> call(String buildingId) => _repo.watchPolls(buildingId);
}
