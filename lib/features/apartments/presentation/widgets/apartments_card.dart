import 'package:flutter/material.dart';
import '../../domain/entity/apartments_entity.dart';

class ApartmentsCard extends StatelessWidget {
  const ApartmentsCard({super.key, required this.entity});

  final ApartmentsEntity entity;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entity.title),
      subtitle: Text(entity.id),
    );
  }
}
