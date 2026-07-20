import 'package:flutter/material.dart';
import '../../domain/entity/announcements_entity.dart';

class AnnouncementsCard extends StatelessWidget {
  const AnnouncementsCard({super.key, required this.entity});

  final AnnouncementsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
