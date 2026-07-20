import 'package:flutter/material.dart';
import '../../domain/entity/auth_entity.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.entity});

  final AuthEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
