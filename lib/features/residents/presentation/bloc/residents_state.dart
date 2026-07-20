import 'package:equatable/equatable.dart';
import '../../domain/entity/residents_entity.dart';

enum ResidentsStatus { initial, loading, success, failure }

class ResidentsState extends Equatable {
  const ResidentsState({
    this.status = ResidentsStatus.initial,
    this.items = const [],
    this.message,
  });

  final ResidentsStatus status;
  final List<ResidentsEntity> items;
  final String? message;

  ResidentsState copyWith({
    ResidentsStatus? status,
    List<ResidentsEntity>? items,
    String? message,
  }) {
    return ResidentsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
