import 'package:equatable/equatable.dart';
import '../../domain/entity/polls_entity.dart';

enum PollsStatus { initial, loading, success, failure }

class PollsState extends Equatable {
  const PollsState({
    this.status = PollsStatus.initial,
    this.items = const [],
    this.message,
  });

  final PollsStatus status;
  final List<PollsEntity> items;
  final String? message;

  PollsState copyWith({
    PollsStatus? status,
    List<PollsEntity>? items,
    String? message,
  }) {
    return PollsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
