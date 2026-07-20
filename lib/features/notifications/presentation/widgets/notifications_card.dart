import 'package:flutter/material.dart';
import '../../domain/entity/notifications_entity.dart';

class NotificationsCard extends StatelessWidget {
  const NotificationsCard({super.key, required this.entity});

  final NotificationsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
