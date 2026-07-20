import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_state.dart';
import '../widgets/analytics_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('analytics_title'))),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          switch (state.status) {
            case AnalyticsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case AnalyticsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case AnalyticsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    AnalyticsCard(entity: state.items[index]),
              );
            case AnalyticsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
