import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/residents_bloc.dart';
import '../bloc/residents_state.dart';
import '../widgets/residents_card.dart';

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('residents_title'))),
      body: BlocBuilder<ResidentsBloc, ResidentsState>(
        builder: (context, state) {
          switch (state.status) {
            case ResidentsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ResidentsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ResidentsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ResidentsCard(entity: state.items[index]),
              );
            case ResidentsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
