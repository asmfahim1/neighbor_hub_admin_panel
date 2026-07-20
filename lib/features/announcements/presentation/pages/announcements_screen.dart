import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/announcements_bloc.dart';
import '../bloc/announcements_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`announcements_plan.md`). This just proves the
/// [AnnouncementsBloc] wiring compiles and renders something for each
/// [AnnouncementsStatus].
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('announcements_title'))),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnnouncementsStatus.initial:
              return const SizedBox.shrink();
            case AnnouncementsStatus.loading:
            case AnnouncementsStatus.mutating:
              return const Center(child: CircularProgressIndicator());
            case AnnouncementsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case AnnouncementsStatus.loaded:
              if (state.announcements.isEmpty) {
                return const Center(child: Text('No announcements yet'));
              }
              return ListView.builder(
                itemCount: state.announcements.length,
                itemBuilder: (_, index) {
                  final announcement = state.announcements[index];
                  return ListTile(
                    title: Text(announcement.title),
                    subtitle: Text(announcement.body),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
