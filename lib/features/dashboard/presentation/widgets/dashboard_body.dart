import 'package:flutter/material.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/models/models.dart';
import '../../../../core/route_handler/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entity/dashboard_entity.dart';
import '../bloc/dashboard_state.dart';
import 'dashboard_card.dart';

class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key, required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == DashboardStatus.initial ||
        state.status == DashboardStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == DashboardStatus.failure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.message ?? 'Dashboard could not be loaded.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dashboard = state.dashboard;
        final contentWidth = constraints.maxWidth;
        final horizontalPadding = contentWidth >= 900 ? 32.0 : 18.0;
        final topPadding = contentWidth >= 900 ? 28.0 : 18.0;

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  24,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DashboardHeader(contentWidth: contentWidth),
                    const SizedBox(height: 18),
                    DashboardOverviewGrid(dashboard: dashboard),
                    if (_hasNoApartments(dashboard)) ...[
                      const SizedBox(height: 18),
                      const DashboardFirstRunBanner(),
                    ],
                    const SizedBox(height: 18),
                    DashboardResponsivePair(
                      left: DashboardFloorOccupancySection(
                        floors: dashboard.floorBreakdown,
                      ),
                      right: DashboardPendingRequestsSection(
                        requests: dashboard.pendingRequests,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DashboardResponsivePair(
                      left: DashboardEngagementSection(dashboard: dashboard),
                      right: const DashboardResidentAppAnalyticsSection(),
                    ),
                    const SizedBox(height: 18),
                    DashboardRecentActivitySection(
                      items: dashboard.recentActivity,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _hasNoApartments(DashboardEntity dashboard) {
    return dashboard.apartmentStatusCounts.values
            .fold<int>(0, (sum, count) => sum + count) ==
        0;
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.contentWidth});

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style:
              Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 6),
        Text(
          'Requests, occupancy, resident activity, and app usage at a glance.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );

    if (contentWidth < 640) return titleBlock;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.buildings),
          icon: const Icon(Icons.apartment_rounded),
          label: const Text('Set up building'),
        ),
      ],
    );
  }
}

class DashboardOverviewGrid extends StatelessWidget {
  const DashboardOverviewGrid({super.key, required this.dashboard});

  final DashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    final counts = dashboard.apartmentStatusCounts;
    final cards = [
      DashboardMetricCardData(
        title: 'Residents',
        value: dashboard.residentCount.toString(),
        subtitle: 'Occupied apartments',
        icon: Icons.groups_2_rounded,
        color: AppColors.success,
      ),
      DashboardMetricCardData(
        title: 'Requests',
        value: dashboard.pendingRequests.length.toString(),
        subtitle: 'Waiting for decision',
        icon: Icons.pending_actions_rounded,
        color: AppColors.accentCopper,
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.residents),
      ),
      DashboardMetricCardData(
        title: 'Occupied',
        value: _count(counts, ApartmentStatus.occupied).toString(),
        subtitle: 'Assigned units',
        icon: Icons.home_work_rounded,
        color: const Color(0xFF2563EB),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.apartments),
      ),
      DashboardMetricCardData(
        title: 'Vacant',
        value: _count(counts, ApartmentStatus.vacant).toString(),
        subtitle: 'Available units',
        icon: Icons.meeting_room_rounded,
        color: const Color(0xFF0D9488),
        onTap: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.apartments),
      ),
      const DashboardMetricCardData(
        title: 'App downloads',
        value: '--',
        subtitle: 'Data source pending',
        icon: Icons.download_rounded,
        color: Color(0xFF7C3AED),
      ),
      const DashboardMetricCardData(
        title: 'Active users',
        value: '--',
        subtitle: 'Realtime source pending',
        icon: Icons.online_prediction_rounded,
        color: Color(0xFFDC2626),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 980
            ? 3
            : width >= 620
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 3.7 : 2.7,
          ),
          itemBuilder: (context, index) =>
              DashboardMetricCard(data: cards[index]),
        );
      },
    );
  }

  int _count(Map<ApartmentStatus, int> counts, ApartmentStatus status) {
    return counts[status] ?? 0;
  }
}

class DashboardResponsivePair extends StatelessWidget {
  const DashboardResponsivePair({
    super.key,
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 860) {
          return Column(
            children: [
              left,
              const SizedBox(height: 18),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: left),
            const SizedBox(width: 18),
            Expanded(flex: 2, child: right),
          ],
        );
      },
    );
  }
}

class DashboardFloorOccupancySection extends StatelessWidget {
  const DashboardFloorOccupancySection({super.key, required this.floors});

  final List<FloorOccupancyEntity> floors;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Floor occupancy',
      subtitle: 'Unit status by floor',
      actionLabel: 'Apartments',
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.apartments),
      child: floors.isEmpty
          ? const DashboardEmptyText('No apartment floors generated yet.')
          : Column(
              children: [
                for (final floor in floors) DashboardFloorRow(floor: floor),
              ],
            ),
    );
  }
}

class DashboardFloorRow extends StatelessWidget {
  const DashboardFloorRow({super.key, required this.floor});

  final FloorOccupancyEntity floor;

  @override
  Widget build(BuildContext context) {
    final occupiedRatio =
        floor.total == 0 ? 0.0 : floor.occupied / floor.total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Floor ${floor.floor}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                '${floor.occupied}/${floor.total} occupied',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: occupiedRatio,
              minHeight: 8,
              backgroundColor: dashboardMutedFill(context),
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DashboardStatusPill(
                label: 'Vacant ${floor.vacant}',
                color: const Color(0xFF0D9488),
              ),
              DashboardStatusPill(
                label: 'Pending ${floor.pending}',
                color: AppColors.accentCopper,
              ),
              DashboardStatusPill(
                label: 'Blocked ${floor.blocked}',
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DashboardPendingRequestsSection extends StatelessWidget {
  const DashboardPendingRequestsSection({super.key, required this.requests});

  final List<ApartmentRequestEntity> requests;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Pending requests',
      subtitle: '${requests.length} waiting',
      actionLabel: 'View all',
      onAction: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.residents),
      child: requests.isEmpty
          ? const DashboardEmptyText('No pending resident requests.')
          : Column(
              children: [
                for (final request in requests.take(5))
                  DashboardRequestTile(request: request),
              ],
            ),
    );
  }
}

class DashboardRequestTile extends StatelessWidget {
  const DashboardRequestTile({super.key, required this.request});

  final ApartmentRequestEntity request;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: dashboardMutedFill(context),
        child: const Icon(Icons.person_outline_rounded),
      ),
      title: Text(
        request.requesterDisplayName ?? request.uid,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('Apartment ${request.apartmentId}'),
      trailing: Text(
        formatter.timeAgo(request.createdAt, fallback: ''),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}

class DashboardEngagementSection extends StatelessWidget {
  const DashboardEngagementSection({super.key, required this.dashboard});

  final DashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Resident engagement',
      subtitle: 'Feed activity summary',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DashboardMiniStat(
                  label: 'Posts',
                  value: dashboard.totalPosts.toString(),
                ),
              ),
              Expanded(
                child: DashboardMiniStat(
                  label: 'Comments',
                  value: dashboard.totalComments.toString(),
                ),
              ),
              Expanded(
                child: DashboardMiniStat(
                  label: 'Reactions',
                  value: dashboard.totalReactions.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Most active residents',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 10),
          if (dashboard.topActiveResidentUids.isEmpty)
            const DashboardEmptyText(
              'Activity appears here after residents post, comment, or react.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final uid in dashboard.topActiveResidentUids)
                  DashboardStatusPill(
                    label: _shortUid(uid),
                    color: const Color(0xFF2563EB),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _shortUid(String uid) {
    return uid.length <= 8 ? uid : '${uid.substring(0, 8)}...';
  }
}

class DashboardResidentAppAnalyticsSection extends StatelessWidget {
  const DashboardResidentAppAnalyticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Resident app analytics',
      subtitle: 'Downloads and realtime users',
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(
                child: DashboardMiniStat(label: 'Downloads', value: '--'),
              ),
              Expanded(
                child: DashboardMiniStat(label: 'Active now', value: '--'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: dashboardMutedFill(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Data source pending. Connect resident app telemetry to Firestore or a Firebase Analytics sync.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardRecentActivitySection extends StatelessWidget {
  const DashboardRecentActivitySection({super.key, required this.items});

  final List<ActivityFeedItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return DashboardPanel(
      title: 'Recent activity',
      subtitle: 'Latest posts and announcements',
      child: items.isEmpty
          ? const DashboardEmptyText(
              'Recent posts and announcements appear here.',
            )
          : Column(
              children: [
                for (final item in items.take(8))
                  DashboardActivityTile(item: item),
              ],
            ),
    );
  }
}

class DashboardActivityTile extends StatelessWidget {
  const DashboardActivityTile({super.key, required this.item});

  final ActivityFeedItemEntity item;

  @override
  Widget build(BuildContext context) {
    final isPost = item.type == ActivityFeedItemType.post;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: DashboardIconBadge(
        icon: isPost ? Icons.forum_rounded : Icons.campaign_rounded,
        color: isPost ? const Color(0xFF2563EB) : AppColors.accentCopper,
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(isPost ? 'Post' : 'Announcement'),
      trailing: Text(
        formatter.timeAgo(item.createdAt, fallback: ''),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}

class DashboardFirstRunBanner extends StatelessWidget {
  const DashboardFirstRunBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final textBlock = Column(
          crossAxisAlignment:
              compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Text(
              'Set up your building',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Generate apartments first so resident requests can be approved.',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: compact
              ? Column(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    textBlock,
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.buildings),
                      child: const Text('Start'),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: textBlock),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.buildings),
                      child: const Text('Start'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
