import 'package:flutter/material.dart';
import '../../domain/entity/analytics_entity.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({super.key, required this.entity});

  final AnalyticsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
