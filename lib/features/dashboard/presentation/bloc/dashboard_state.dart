import 'package:equatable/equatable.dart';
import '../../domain/entity/dashboard_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.items = const [],
    this.message,
  });

  final DashboardStatus status;
  final List<DashboardEntity> items;
  final String? message;

  DashboardState copyWith({
    DashboardStatus? status,
    List<DashboardEntity>? items,
    String? message,
  }) {
    return DashboardState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
