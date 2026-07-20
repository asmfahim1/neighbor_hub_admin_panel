import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/buildings_bloc.dart';
import '../bloc/buildings_state.dart';
import '../widgets/buildings_card.dart';

class BuildingsScreen extends StatelessWidget {
  const BuildingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('buildings_title'))),
      body: BlocBuilder<BuildingsBloc, BuildingsState>(
        builder: (context, state) {
          switch (state.status) {
            case BuildingsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case BuildingsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case BuildingsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    BuildingsCard(entity: state.items[index]),
              );
            case BuildingsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
