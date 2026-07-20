import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/moderation_bloc.dart';
import '../bloc/moderation_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`moderation_plan.md`). This just proves the [ModerationBloc]
/// wiring compiles and renders something for each [ModerationStatus].
class ModerationScreen extends StatelessWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('moderation_title'))),
      body: BlocBuilder<ModerationBloc, ModerationState>(
        builder: (context, state) {
          switch (state.status) {
            case ModerationStatus.initial:
              return const SizedBox.shrink();
            case ModerationStatus.loading:
            case ModerationStatus.mutating:
              return const Center(child: CircularProgressIndicator());
            case ModerationStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case ModerationStatus.loaded:
              if (state.feed.isEmpty) {
                return const Center(child: Text('No posts yet'));
              }
              return ListView.builder(
                itemCount: state.feed.length,
                itemBuilder: (_, index) {
                  final post = state.feed[index];
                  return ListTile(
                    title: Text(post.text),
                    subtitle: Text(
                      '${post.isPinned ? "Pinned" : ""} ${post.isLocked ? "Locked" : ""}'.trim(),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
