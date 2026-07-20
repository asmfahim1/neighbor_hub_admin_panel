import 'package:equatable/equatable.dart';
import '../../domain/entity/announcements_entity.dart';

enum AnnouncementsStatus { initial, loading, success, failure }

class AnnouncementsState extends Equatable {
  const AnnouncementsState({
    this.status = AnnouncementsStatus.initial,
    this.items = const [],
    this.message,
  });

  final AnnouncementsStatus status;
  final List<AnnouncementsEntity> items;
  final String? message;

  AnnouncementsState copyWith({
    AnnouncementsStatus? status,
    List<AnnouncementsEntity>? items,
    String? message,
  }) {
    return AnnouncementsState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
