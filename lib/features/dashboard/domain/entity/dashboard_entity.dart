import 'package:equatable/equatable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/models/models.dart';

/// Per-floor occupancy breakdown — `admen_web_app_ui_functionality.md` §7.2
/// ("Floor vs. Occupancy breakdown"), computed client-side from a single
/// realtime `apartments` listener.
class FloorOccupancyEntity extends Equatable {
  const FloorOccupancyEntity({
    required this.floor,
    required this.total,
    required this.occupied,
    required this.vacant,
    required this.pending,
    required this.blocked,
  });

  final int floor;
  final int total;
  final int occupied;
  final int vacant;
  final int pending;
  final int blocked;

  @override
  List<Object?> get props => [floor, total, occupied, vacant, pending, blocked];
}

enum ActivityFeedItemType { post, announcement }

/// One row of the Dashboard's "Recent activity feed" (§7.2) — merged from
/// `posts` and `announcements`, ordered by `createdAt desc`.
///
/// Deliberately excludes recently-decided `apartment_requests` for now: that
/// would need a `whereIn(status, [approved, rejected]) + orderBy(decidedAt)`
/// query, which needs a composite index not declared in
/// `05_FIRESTORE_DATABASE.md` §5 — flagged as a follow-up rather than shipping
/// an unindexed query that would throw at runtime.
class ActivityFeedItemEntity extends Equatable {
  const ActivityFeedItemEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final ActivityFeedItemType type;
  final String title;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, type, title, createdAt];
}

/// The Dashboard's full read-only snapshot (§7.2) — computed client-side from
/// four independent realtime listeners (apartments, pending requests, recent
/// posts, recent announcements). No aggregation queries or `analytics`
/// collection; acceptable at single-building/~100-resident scale (§7.9).
class DashboardEntity extends Equatable {
  const DashboardEntity({
    this.apartmentStatusCounts = const {},
    this.floorBreakdown = const [],
    this.residentCount = 0,
    this.pendingRequests = const [],
    this.totalPosts = 0,
    this.totalComments = 0,
    this.totalReactions = 0,
    this.topActiveResidentUids = const [],
    this.recentActivity = const [],
  });

  final Map<ApartmentStatus, int> apartmentStatusCounts;
  final List<FloorOccupancyEntity> floorBreakdown;
  final int residentCount;
  final List<ApartmentRequestEntity> pendingRequests;
  final int totalPosts;
  final int totalComments;
  final int totalReactions;

  /// Top-N most active residents (by post + comment + reaction count),
  /// highest first.
  final List<String> topActiveResidentUids;
  final List<ActivityFeedItemEntity> recentActivity;

  /// Recomputes the full snapshot from the four raw collections — pure,
  /// synchronous, and independent of *how* each list arrived (realtime
  /// listener today, anything else later), so it's trivially unit-testable.
  factory DashboardEntity.compute({
    required List<ApartmentEntity> apartments,
    required List<ApartmentRequestEntity> pendingRequests,
    required List<PostEntity> posts,
    required List<AnnouncementEntity> announcements,
    int recentActivityLimit = 20,
    int topActiveResidentsLimit = 5,
  }) {
    final statusCounts = <ApartmentStatus, int>{
      for (final status in ApartmentStatus.values) status: 0,
    };
    final byFloor = <int, List<ApartmentEntity>>{};
    for (final apartment in apartments) {
      statusCounts[apartment.status] = (statusCounts[apartment.status] ?? 0) + 1;
      byFloor.putIfAbsent(apartment.floor, () => []).add(apartment);
    }

    final floorBreakdown = byFloor.entries.map((entry) {
      final unitsOnFloor = entry.value;
      return FloorOccupancyEntity(
        floor: entry.key,
        total: unitsOnFloor.length,
        occupied: unitsOnFloor.where((a) => a.status == ApartmentStatus.occupied).length,
        vacant: unitsOnFloor.where((a) => a.status == ApartmentStatus.vacant).length,
        pending: unitsOnFloor.where((a) => a.status == ApartmentStatus.pendingApproval).length,
        blocked: unitsOnFloor.where((a) => a.status == ApartmentStatus.blocked).length,
      );
    }).toList()
      ..sort((a, b) => a.floor.compareTo(b.floor));

    final residentCount = statusCounts[ApartmentStatus.occupied] ?? 0;

    final totalComments = posts.fold<int>(0, (sum, p) => sum + p.commentCount);
    final totalReactions = posts.fold<int>(0, (sum, p) => sum + p.reactionCount);

    final activityScores = <String, int>{};
    for (final post in posts) {
      final authorUid = post.authorUid;
      if (authorUid == null) continue; // anonymous — no attribution possible
      final score = 1 + post.commentCount + post.reactionCount;
      activityScores[authorUid] = (activityScores[authorUid] ?? 0) + score;
    }
    final topActiveResidentUids = (activityScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(topActiveResidentsLimit)
        .map((e) => e.key)
        .toList();

    final recentActivity = <ActivityFeedItemEntity>[
      ...posts.map((p) => ActivityFeedItemEntity(
            id: p.id,
            type: ActivityFeedItemType.post,
            title: p.text,
            createdAt: p.createdAt,
          )),
      ...announcements.map((a) => ActivityFeedItemEntity(
            id: a.id,
            type: ActivityFeedItemType.announcement,
            title: a.title,
            createdAt: a.createdAt,
          )),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DashboardEntity(
      apartmentStatusCounts: statusCounts,
      floorBreakdown: floorBreakdown,
      residentCount: residentCount,
      pendingRequests: pendingRequests,
      totalPosts: posts.length,
      totalComments: totalComments,
      totalReactions: totalReactions,
      topActiveResidentUids: topActiveResidentUids,
      recentActivity: recentActivity.take(recentActivityLimit).toList(),
    );
  }

  @override
  List<Object?> get props => [
        apartmentStatusCounts,
        floorBreakdown,
        residentCount,
        pendingRequests,
        totalPosts,
        totalComments,
        totalReactions,
        topActiveResidentUids,
        recentActivity,
      ];
}
