import 'package:flutter/material.dart';
import '../../domain/entity/moderation_entity.dart';

class ModerationCard extends StatelessWidget {
  const ModerationCard({super.key, required this.entity});

  final ModerationEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
