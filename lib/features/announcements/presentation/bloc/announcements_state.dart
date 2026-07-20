import 'package:equatable/equatable.dart';

import '../../domain/entity/announcements_entity.dart';

enum AnnouncementsStatus { initial, loading, loaded, mutating, failure }

class AnnouncementsState extends Equatable {
  const AnnouncementsState({
    this.status = AnnouncementsStatus.initial,
    this.announcements = const [],
    this.message,
  });

  final AnnouncementsStatus status;
  final List<AnnouncementEntity> announcements;
  final String? message;

  AnnouncementsState copyWith({
    AnnouncementsStatus? status,
    List<AnnouncementEntity>? announcements,
    String? message,
    bool clearMessage = false,
  }) {
    return AnnouncementsState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, announcements, message];
}
