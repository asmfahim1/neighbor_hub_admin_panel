import 'package:flutter/material.dart';
import '../../domain/entity/profile_entity.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.entity});

  final ProfileEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
