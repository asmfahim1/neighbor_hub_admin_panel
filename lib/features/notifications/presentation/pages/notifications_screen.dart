import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';
import '../widgets/notifications_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('notifications_title'))),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          switch (state.status) {
            case NotificationsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case NotificationsStatus.failure:
              return Center(child: Text(state.message ?? 'Error'));
            case NotificationsStatus.success:
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (_, index) =>
                    NotificationsCard(entity: state.items[index]),
              );
            case NotificationsStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
