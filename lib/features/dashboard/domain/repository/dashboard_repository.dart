import '../../../../core/models/models.dart';

/// Four independent, building-scoped realtime listeners — the Dashboard
/// bloc combines their emissions client-side via `DashboardEntity.compute`.
/// No combined/aggregated stream at this layer, to avoid an `rxdart`
/// dependency for a single-building/~100-resident scale screen (§7.9).
abstract class DashboardRepository {
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);

  Stream<List<ApartmentRequestEntity>> watchPendingRequests(String buildingId);

  Stream<List<PostEntity>> watchRecentPosts(String buildingId, {int limit});

  Stream<List<AnnouncementEntity>> watchRecentAnnouncements(String buildingId, {int limit});
}
