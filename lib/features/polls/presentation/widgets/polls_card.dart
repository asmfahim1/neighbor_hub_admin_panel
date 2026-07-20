import 'package:flutter/material.dart';
import '../../domain/entity/polls_entity.dart';

class PollsCard extends StatelessWidget {
  const PollsCard({super.key, required this.entity});

  final PollsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
