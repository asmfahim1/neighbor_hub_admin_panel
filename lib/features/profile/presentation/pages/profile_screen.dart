import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`profile_plan.md`). This just proves the [ProfileBloc] wiring
/// compiles and renders something for each [ProfileStatus].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_title'))),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          switch (state.status) {
            case ProfileStatus.initial:
            case ProfileStatus.loading:
            case ProfileStatus.saving:
              return const Center(child: CircularProgressIndicator());
            case ProfileStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case ProfileStatus.signedOut:
              return const Center(child: Text('Signed out'));
            case ProfileStatus.loaded:
              final profile = state.profile;
              if (profile == null) return const SizedBox.shrink();
              return Center(child: Text(profile.displayName));
          }
        },
      ),
    );
  }
}
