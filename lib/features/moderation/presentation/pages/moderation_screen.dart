import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_state.dart';
import '../widgets/moderation_card.dart';

class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('moderation_title'))),
      body: BlocBuilder<ModerationBloc, ModerationState>(
        builder: (context, state) {
          switch (state.status) {
            case ModerationStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ModerationStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ModerationStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ModerationCard(entity: state.items[index]),
              );
            case ModerationStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
