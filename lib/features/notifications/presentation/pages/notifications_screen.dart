import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';

/// Placeholder only — real UI/UX is a separate pass once the design is
/// ready (`notifications_plan.md`). This just proves the [NotificationsBloc]
/// wiring compiles and renders something for each [NotificationsStatus].
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('notifications_title'))),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          switch (state.status) {
            case NotificationsStatus.initial:
            case NotificationsStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case NotificationsStatus.failure:
              return Center(child: Text(state.message ?? 'Something went wrong.'));
            case NotificationsStatus.loaded:
              final notifications = state.visibleNotifications;
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications'));
              }
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (_, index) {
                  final notification = notifications[index];
                  return ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.body),
                    trailing: notification.isRead ? null : const Icon(Icons.circle, size: 8),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
