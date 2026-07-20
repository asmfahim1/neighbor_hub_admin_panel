import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('dashboard_title'))),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case DashboardStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case DashboardStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    DashboardCard(entity: state.items[index]),
              );
            case DashboardStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
