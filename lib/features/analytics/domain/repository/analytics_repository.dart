import '../../../../core/models/models.dart';

/// Three independent, building-scoped realtime listeners — the Analytics
/// bloc combines their emissions client-side via `AnalyticsEntity.compute`.
/// No combined/aggregated stream at this layer, to avoid an `rxdart`
/// dependency for a single-building/~100-resident scale screen (§7.9).
abstract class AnalyticsRepository {
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);

  Stream<List<PostEntity>> watchPosts(String buildingId, {int limit});

  Stream<List<PollEntity>> watchPolls(String buildingId);
}
