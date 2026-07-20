import 'package:flutter/material.dart';
import '../../domain/entity/buildings_entity.dart';

class BuildingsCard extends StatelessWidget {
  const BuildingsCard({super.key, required this.entity});

  final BuildingsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
