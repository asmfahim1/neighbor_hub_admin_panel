import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/apartments_bloc.dart';
import '../bloc/apartments_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`apartments_plan.md`). This just proves the [ApartmentsBloc] wiring
/// compiles and renders something for each [ApartmentsStatus].
class ApartmentsScreen extends StatelessWidget {
  const ApartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('apartments_title'))),
      body: BlocBuilder<ApartmentsBloc, ApartmentsState>(
        builder: (context, state) {
          switch (state.status) {
            case ApartmentsStatus.initial:
              return const SizedBox.shrink();
            case ApartmentsStatus.loading:
            case ApartmentsStatus.mutating:
              return const Center(child: CircularProgressIndicator());
            case ApartmentsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case ApartmentsStatus.loaded:
              if (state.apartments.isEmpty) {
                return const Center(child: Text('No apartments yet'));
              }
              return ListView.builder(
                itemCount: state.apartments.length,
                itemBuilder: (_, index) {
                  final apartment = state.apartments[index];
                  return ListTile(
                    title: Text(apartment.number),
                    subtitle: Text('Floor ${apartment.floor} — ${apartment.status.value}'),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
