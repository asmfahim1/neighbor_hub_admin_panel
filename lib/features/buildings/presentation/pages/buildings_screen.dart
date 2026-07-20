import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/buildings_bloc.dart';
import '../bloc/buildings_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`buildings_plan.md`). This just proves the [BuildingsBloc] wiring
/// compiles and renders something for each [BuildingsStatus].
class BuildingsScreen extends StatelessWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('buildings_title'))),
      body: BlocBuilder<BuildingsBloc, BuildingsState>(
        builder: (context, state) {
          switch (state.status) {
            case BuildingsStatus.initial:
              return const SizedBox.shrink();
            case BuildingsStatus.loading:
            case BuildingsStatus.saving:
            case BuildingsStatus.generating:
              return const Center(child: CircularProgressIndicator());
            case BuildingsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case BuildingsStatus.loaded:
              final building = state.building;
              if (building == null) {
                return const Center(child: Text('Set up your building'));
              }
              return Center(child: Text(building.name));
          }
        },
      ),
    );
  }
}
