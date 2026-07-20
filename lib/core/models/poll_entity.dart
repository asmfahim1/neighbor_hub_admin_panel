import 'package:equatable/equatable.dart';

import '../constants/poll_status.dart';
import '../firebase/firestore_converters.dart';

/// One entry of `polls/{pollId}.options` — `05_FIRESTORE_DATABASE.md` §3.11.
class PollOptionEntity extends Equatable {
  const PollOptionEntity({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  final String id;
  final String text;
  final int voteCount;

  factory PollOptionEntity.fromJson(Map<String, dynamic> json) {
    return PollOptionEntity(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'voteCount': voteCount,
      };

  PollOptionEntity copyWith({int? voteCount}) => PollOptionEntity(
        id: id,
        text: text,
        voteCount: voteCount ?? this.voteCount,
      );

  @override
  List<Object?> get props => [id, text, voteCount];
}

/// Mirrors `polls/{pollId}` — `05_FIRESTORE_DATABASE.md` §3.11.
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

  factory PollEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    return PollEntity(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: rawOptions
          .map((o) => PollOptionEntity.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList(),
      status: PollStatus.fromValue(json['status']?.toString()),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
      closesAt: FirestoreConverters.toDate(json['closesAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
        'status': status.value,
        'createdBy': createdBy,
        'createdAt': FirestoreConverters.fromDate(createdAt),
        'closesAt': FirestoreConverters.fromDate(closesAt),
      };

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
/// Document ID is the voter's uid; a vote is immutable once cast.
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

  factory PollVoteEntity.fromJson(
    Map<String, dynamic> json, {
    required String uid,
    required String pollId,
  }) {
    return PollVoteEntity(
      uid: uid,
      pollId: pollId,
      optionId: json['optionId']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [uid, pollId, optionId, createdAt];
}
