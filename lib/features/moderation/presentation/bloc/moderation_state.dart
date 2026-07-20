import 'package:equatable/equatable.dart';
import '../../domain/entity/moderation_entity.dart';

enum ModerationStatus { initial, loading, success, failure }

class ModerationState extends Equatable {
  const ModerationState({
    this.status = ModerationStatus.initial,
    this.items = const [],
    this.message,
  });

  final ModerationStatus status;
  final List<ModerationEntity> items;
  final String? message;

  ModerationState copyWith({
    ModerationStatus? status,
    List<ModerationEntity>? items,
    String? message,
  }) {
    return ModerationState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
