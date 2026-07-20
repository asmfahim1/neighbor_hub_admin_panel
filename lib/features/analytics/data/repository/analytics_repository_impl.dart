import 'package:injectable/injectable.dart';

import '../../../../core/models/models.dart';
import '../../domain/repository/analytics_repository.dart';
import '../source/analytics_remote_source.dart';

@LazySingleton(as: AnalyticsRepository)
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remote);

  final AnalyticsRemoteSource _remote;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) =>
      _remote.watchApartments(buildingId);

  @override
  Stream<List<PostEntity>> watchPosts(String buildingId, {int limit = 500}) =>
      _remote.watchPosts(buildingId, limit: limit);

  @override
  Stream<List<PollEntity>> watchPolls(String buildingId) => _remote.watchPolls(buildingId);
}
