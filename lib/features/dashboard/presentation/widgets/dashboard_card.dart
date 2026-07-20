import 'package:flutter/material.dart';
import '../../domain/entity/dashboard_entity.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({super.key, required this.entity});

  final DashboardEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
