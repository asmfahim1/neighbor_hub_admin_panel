import 'package:equatable/equatable.dart';

import '../constants/poll_status.dart';

/// One entry of `polls/{pollId}.options` — `05_FIRESTORE_DATABASE.md` §3.11.
///
/// Pure domain object. Never fetched/parsed as its own top-level document —
/// it only ever exists embedded in a poll's `options` array, so its
/// JSON shape is parsed/serialized entirely by [PollModel]
/// (`poll_model.dart`), not by this class.
class PollOptionEntity extends Equatable {
  const PollOptionEntity({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  final String id;
  final String text;
  final int voteCount;

  PollOptionEntity copyWith({int? voteCount}) => PollOptionEntity(
        id: id,
        text: text,
        voteCount: voteCount ?? this.voteCount,
      );

  @override
  List<Object?> get props => [id, text, voteCount];
}

/// Mirrors `polls/{pollId}` — `05_FIRESTORE_DATABASE.md` §3.11.
///
/// Pure domain object — no Firestore/JSON knowledge. See [PollModel]
/// (`poll_model.dart`) for parsing/serialization.
class PollEntity extends Equatable {
  const PollEntity({
    required this.id,
    required this.buildingId,
    required this.question,
    required this.options,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.closesAt,
  });

  final String id;
  final String buildingId;
  final String question;
  final List<PollOptionEntity> options;
  final PollStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? closesAt;

  int get totalVotes => options.fold(0, (sum, o) => sum + o.voteCount);

  /// Client-side expiry check — Phase 1 has no server-side cron
  /// (`admen_web_app_ui_functionality.md` §7.8).
  bool get isExpired => closesAt != null && DateTime.now().isAfter(closesAt!);

  PollEntity copyWith({
    List<PollOptionEntity>? options,
    PollStatus? status,
  }) {
    return PollEntity(
      id: id,
      buildingId: buildingId,
      question: question,
      options: options ?? this.options,
      status: status ?? this.status,
      createdBy: createdBy,
      createdAt: createdAt,
      closesAt: closesAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, buildingId, question, options, status, createdBy, createdAt, closesAt];
}

/// Mirrors `polls/{pollId}/votes/{uid}` — `05_FIRESTORE_DATABASE.md` §3.12.
/// Document ID is the voter's uid; a vote is immutable once cast. Pure
/// domain object — see [PollVoteModel] for parsing/serialization.
class PollVoteEntity extends Equatable {
  const PollVoteEntity({
    required this.uid,
    required this.pollId,
    required this.optionId,
    required this.createdAt,
  });

  final String uid;
  final String pollId;
  final String optionId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [uid, pollId, optionId, createdAt];
}
