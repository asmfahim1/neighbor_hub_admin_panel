import 'package:equatable/equatable.dart';
import '../../domain/entity/buildings_entity.dart';

enum BuildingsStatus { initial, loading, success, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.items = const [],
    this.message,
  });

  final BuildingsStatus status;
  final List<BuildingsEntity> items;
  final String? message;

  BuildingsState copyWith({
    BuildingsStatus? status,
    List<BuildingsEntity>? items,
    String? message,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
