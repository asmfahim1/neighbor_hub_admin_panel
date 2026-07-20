import 'package:equatable/equatable.dart';

import '../../domain/entity/analytics_entity.dart';

enum AnalyticsStatus { initial, loading, loaded, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.analytics = const AnalyticsEntity(),
    this.message,
  });

  final AnalyticsStatus status;
  final AnalyticsEntity analytics;
  final String? message;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsEntity? analytics,
    String? message,
    bool clearMessage = false,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, analytics, message];
}
