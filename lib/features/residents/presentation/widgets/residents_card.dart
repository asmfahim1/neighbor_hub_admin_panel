import 'package:flutter/material.dart';
import '../../domain/entity/residents_entity.dart';

class ResidentsCard extends StatelessWidget {
  const ResidentsCard({super.key, required this.entity});

  final ResidentsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
