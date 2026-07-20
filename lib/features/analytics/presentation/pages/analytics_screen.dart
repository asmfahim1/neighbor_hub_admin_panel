import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`analytics_plan.md`). This just proves the [AnalyticsBloc] wiring
/// compiles and renders something for each [AnalyticsStatus].
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('analytics_title'))),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnalyticsStatus.initial:
            case AnalyticsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AnalyticsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case AnalyticsStatus.loaded:
              final analytics = state.analytics;
              return ListView(
                children: [
                  ListTile(title: Text('Residents: ${analytics.residentCount}')),
                  ListTile(
                    title: Text(
                      'Occupancy: ${(analytics.occupancyRate * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                  ListTile(title: Text('Posts: ${analytics.totalPosts}')),
                  ListTile(title: Text('Comments: ${analytics.totalComments}')),
                  ListTile(title: Text('Reactions: ${analytics.totalReactions}')),
                  ListTile(title: Text('Active polls: ${analytics.pollParticipation.length}')),
                ],
              );
          }
        },
      ),
    );
  }
}
