import 'package:equatable/equatable.dart';
import '../../domain/entity/analytics_entity.dart';

enum AnalyticsStatus { initial, loading, success, failure }

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.items = const [],
    this.message,
  });

  final AnalyticsStatus status;
  final List<AnalyticsEntity> items;
  final String? message;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<AnalyticsEntity>? items,
    String? message,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
