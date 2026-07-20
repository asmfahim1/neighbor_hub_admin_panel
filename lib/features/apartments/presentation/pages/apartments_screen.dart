import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/apartments_bloc.dart';
import '../bloc/apartments_state.dart';
import '../widgets/apartments_card.dart';

class ApartmentsScreen extends StatelessWidget {
  const ApartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('apartments_title'))),
      body: BlocBuilder<ApartmentsBloc, ApartmentsState>(
        builder: (context, state) {
          switch (state.status) {
            case ApartmentsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ApartmentsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case ApartmentsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    ApartmentsCard(entity: state.items[index]),
              );
            case ApartmentsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
