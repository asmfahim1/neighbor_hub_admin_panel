import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/announcements_bloc.dart';
import '../bloc/announcements_state.dart';
import '../widgets/announcements_card.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('announcements_title'))),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnnouncementsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AnnouncementsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case AnnouncementsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    AnnouncementsCard(entity: state.items[index]),
              );
            case AnnouncementsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
