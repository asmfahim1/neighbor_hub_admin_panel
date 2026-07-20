import 'package:equatable/equatable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/constants/poll_status.dart';
import '../../../../core/models/models.dart';

/// One day's post volume — `admen_web_app_ui_functionality.md` §7.9
/// ("post/comment/reaction volume over time"). Built purely from the
/// `createdAt` of posts in the current fetch window; there is no stored
/// time-series/snapshot collection in `05_FIRESTORE_DATABASE.md`, so this is
/// a same-window breakdown, not true historical trend data.
class DailyPostVolumeEntity extends Equatable {
  const DailyPostVolumeEntity({required this.day, required this.postCount});

  /// Date-only (local midnight) — the day this bucket represents.
  final DateTime day;
  final int postCount;

  @override
  List<Object?> get props => [day, postCount];
}

/// Per-poll participation — `totalVotes` ÷ [AnalyticsEntity.residentCount].
class PollParticipationEntity extends Equatable {
  const PollParticipationEntity({
    required this.pollId,
    required this.question,
    required this.status,
    required this.totalVotes,
    required this.participationRate,
  });

  final String pollId;
  final String question;
  final PollStatus status;
  final int totalVotes;

  /// 0..1; `0` when there are no residents yet (avoids a divide-by-zero).
  final double participationRate;

  @override
  List<Object?> get props => [pollId, question, status, totalVotes, participationRate];
}

/// The Analytics screen's full read-only snapshot (§7.9) — a deeper,
/// chart-oriented sibling of `DashboardEntity`, computed client-side from
/// three independent realtime listeners (apartments, posts, polls). No
/// `analytics` collection and no aggregation queries, by design; acceptable
/// at single-building/~100-resident scale — flagged if that changes.
class AnalyticsEntity extends Equatable {
  const AnalyticsEntity({
    this.apartmentStatusCounts = const {},
    this.residentCount = 0,
    this.occupancyRate = 0,
    this.totalPosts = 0,
    this.totalComments = 0,
    this.totalReactions = 0,
    this.categoryBreakdown = const {},
    this.postsByDay = const [],
    this.topActiveResidentUids = const [],
    this.pollParticipation = const [],
  });

  final Map<ApartmentStatus, int> apartmentStatusCounts;
  final int residentCount;

  /// `occupied` ÷ total apartments; `0` when there are no apartments yet.
  final double occupancyRate;

  final int totalPosts;
  final int totalComments;
  final int totalReactions;

  /// Keyed by `"discussion"`/`"recommendation"`/`"help"`/`"service"`/
  /// `"anonymous"`/`"uncategorized"` — a post is bucketed as `"anonymous"`
  /// whenever `isAnonymous == true` (regardless of `category`, since a post
  /// can carry a category and still be anonymous), otherwise by its
  /// `category`, falling back to `"uncategorized"` when `category` is null
  /// but `isAnonymous` is false (shouldn't normally happen per
  /// `03_RESIDENT_SYSTEM.md` §6.1's default rule, but handled defensively).
  final Map<String, int> categoryBreakdown;

  /// Ascending by day, built only from posts in the current fetch window
  /// (see `analytics_plan.md` for why this isn't true historical trend data).
  final List<DailyPostVolumeEntity> postsByDay;

  /// Top-N most active residents (by post + comment + reaction count),
  /// highest first.
  final List<String> topActiveResidentUids;

  final List<PollParticipationEntity> pollParticipation;

  /// Recomputes the full snapshot from the three raw collections — pure,
  /// synchronous, and trivially unit-testable.
  factory AnalyticsEntity.compute({
    required List<ApartmentEntity> apartments,
    required List<PostEntity> posts,
    required List<PollEntity> polls,
    int topActiveResidentsLimit = 5,
  }) {
    final statusCounts = <ApartmentStatus, int>{
      for (final status in ApartmentStatus.values) status: 0,
    };
    for (final apartment in apartments) {
      statusCounts[apartment.status] = (statusCounts[apartment.status] ?? 0) + 1;
    }
    final residentCount = statusCounts[ApartmentStatus.occupied] ?? 0;
    final occupancyRate = apartments.isEmpty ? 0.0 : residentCount / apartments.length;

    final totalComments = posts.fold<int>(0, (sum, p) => sum + p.commentCount);
    final totalReactions = posts.fold<int>(0, (sum, p) => sum + p.reactionCount);

    final categoryBreakdown = <String, int>{};
    for (final post in posts) {
      final bucket = post.isAnonymous ? 'anonymous' : (post.category.valueOrNull ?? 'uncategorized');
      categoryBreakdown[bucket] = (categoryBreakdown[bucket] ?? 0) + 1;
    }

    final volumeByDay = <DateTime, int>{};
    for (final post in posts) {
      final createdAt = post.createdAt;
      final day = DateTime(createdAt.year, createdAt.month, createdAt.day);
      volumeByDay[day] = (volumeByDay[day] ?? 0) + 1;
    }
    final postsByDay = volumeByDay.entries
        .map((entry) => DailyPostVolumeEntity(day: entry.key, postCount: entry.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));

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

    final pollParticipation = polls
        .map((poll) => PollParticipationEntity(
              pollId: poll.id,
              question: poll.question,
              status: poll.status,
              totalVotes: poll.totalVotes,
              participationRate:
                  residentCount == 0 ? 0.0 : (poll.totalVotes / residentCount).clamp(0.0, 1.0),
            ))
        .toList();

    return AnalyticsEntity(
      apartmentStatusCounts: statusCounts,
      residentCount: residentCount,
      occupancyRate: occupancyRate,
      totalPosts: posts.length,
      totalComments: totalComments,
      totalReactions: totalReactions,
      categoryBreakdown: categoryBreakdown,
      postsByDay: postsByDay,
      topActiveResidentUids: topActiveResidentUids,
      pollParticipation: pollParticipation,
    );
  }

  @override
  List<Object?> get props => [
        apartmentStatusCounts,
        residentCount,
        occupancyRate,
        totalPosts,
        totalComments,
        totalReactions,
        categoryBreakdown,
        postsByDay,
        topActiveResidentUids,
        pollParticipation,
      ];
}
