import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/polls_bloc.dart';
import '../bloc/polls_state.dart';
import '../widgets/polls_card.dart';

class PollsScreen extends StatelessWidget {
  const PollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('polls_title'))),
      body: BlocBuilder<PollsBloc, PollsState>(
        builder: (context, state) {
          switch (state.status) {
            case PollsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case PollsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case PollsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    PollsCard(entity: state.items[index]),
              );
            case PollsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
