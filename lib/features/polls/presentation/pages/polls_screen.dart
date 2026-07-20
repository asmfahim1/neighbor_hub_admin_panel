import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/polls_bloc.dart';
import '../bloc/polls_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`polls_plan.md`). This just proves the [PollsBloc] wiring compiles
/// and renders something for each [PollsStatus].
class PollsScreen extends StatelessWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('polls_title'))),
      body: BlocBuilder<PollsBloc, PollsState>(
        builder: (context, state) {
          switch (state.status) {
            case PollsStatus.initial:
              return const SizedBox.shrink();
            case PollsStatus.loading:
            case PollsStatus.mutating:
              return const Center(child: CircularProgressIndicator());
            case PollsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case PollsStatus.loaded:
              if (state.polls.isEmpty) {
                return const Center(child: Text('No polls yet'));
              }
              return ListView.builder(
                itemCount: state.polls.length,
                itemBuilder: (_, index) {
                  final poll = state.polls[index];
                  return ListTile(
                    title: Text(poll.question),
                    subtitle: Text('${poll.status.value} — ${poll.totalVotes} votes'),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
