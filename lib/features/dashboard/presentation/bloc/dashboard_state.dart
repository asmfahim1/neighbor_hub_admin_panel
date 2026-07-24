import 'package:equatable/equatable.dart';

import '../../domain/entity/dashboard_entity.dart';

enum DashboardStatus { initial, loading, loaded, failure }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.dashboard = const DashboardEntity(),
    this.message,
    this.isPreview = false,
  });

  final DashboardStatus status;
  final DashboardEntity dashboard;
  final String? message;
  final bool isPreview;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardEntity? dashboard,
    String? message,
    bool clearMessage = false,
    bool? isPreview,
  }) {
    return DashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      message: clearMessage ? null : (message ?? this.message),
      isPreview: isPreview ?? this.isPreview,
    );
  }

  @override
  List<Object?> get props => [status, dashboard, message, isPreview];
}
