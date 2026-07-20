import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`dashboard_plan.md`). This just proves the [DashboardBloc] wiring
/// compiles and renders something for each [DashboardStatus].
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('dashboard_title'))),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.initial:
            case DashboardStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case DashboardStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case DashboardStatus.loaded:
              final dashboard = state.dashboard;
              return ListView(
                children: [
                  ListTile(title: Text('Residents: ${dashboard.residentCount}')),
                  ListTile(title: Text('Pending requests: ${dashboard.pendingRequests.length}')),
                  ListTile(title: Text('Posts: ${dashboard.totalPosts}')),
                  ListTile(title: Text('Comments: ${dashboard.totalComments}')),
                  ListTile(title: Text('Reactions: ${dashboard.totalReactions}')),
                ],
              );
          }
        },
      ),
    );
  }
}
