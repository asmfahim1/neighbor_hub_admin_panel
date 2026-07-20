import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/residents_bloc.dart';
import '../bloc/residents_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`residents_plan.md`). This just proves the [ResidentsBloc] wiring
/// compiles and renders something for each [ResidentsStatus].
class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('residents_title'))),
      body: BlocBuilder<ResidentsBloc, ResidentsState>(
        builder: (context, state) {
          switch (state.status) {
            case ResidentsStatus.initial:
              return const SizedBox.shrink();
            case ResidentsStatus.loading:
            case ResidentsStatus.mutating:
              return const Center(child: CircularProgressIndicator());
            case ResidentsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case ResidentsStatus.loaded:
              if (state.directory.isNotEmpty) {
                return ListView.builder(
                  itemCount: state.directory.length,
                  itemBuilder: (_, index) {
                    final resident = state.directory[index];
                    return ListTile(title: Text(resident.displayName));
                  },
                );
              }
              if (state.pendingRequests.isNotEmpty) {
                return ListView.builder(
                  itemCount: state.pendingRequests.length,
                  itemBuilder: (_, index) {
                    final request = state.pendingRequests[index];
                    return ListTile(
                      title: Text(request.requesterDisplayName ?? request.uid),
                      subtitle: Text('Apartment ${request.apartmentId}'),
                    );
                  },
                );
              }
              return const Center(child: Text('No residents yet'));
          }
        },
      ),
    );
  }
}
