import 'poll_entity.dart';
import '../constants/poll_status.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `polls/{pollId}`. Owns parsing/serialization of the
/// embedded `options` array too — [PollOptionEntity] itself stays JSON-free
/// since it's never fetched as its own document (see its doc comment). See
/// `lib/core/models/README.md` for why Model extends Entity.
class PollModel extends PollEntity {
  const PollModel({
    required super.id,
    required super.buildingId,
    required super.question,
    required super.options,
    required super.status,
    required super.createdBy,
    required super.createdAt,
    super.closesAt,
  });

  factory PollModel.fromJson(Map<String, dynamic> json, {required String id}) {
    final rawOptions = json['options'] as List<dynamic>? ?? const [];
    return PollModel(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: rawOptions.map((raw) {
        final map = Map<String, dynamic>.from(raw as Map);
        return PollOptionEntity(
          id: map['id']?.toString() ?? '',
          text: map['text']?.toString() ?? '',
          voteCount: (map['voteCount'] as num?)?.toInt() ?? 0,
        );
      }).toList(),
      status: PollStatus.fromValue(json['status']?.toString()),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
      closesAt: FirestoreConverters.toDate(json['closesAt']),
    );
  }

  factory PollModel.fromEntity(PollEntity entity) {
    return PollModel(
      id: entity.id,
      buildingId: entity.buildingId,
      question: entity.question,
      options: entity.options,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      closesAt: entity.closesAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'question': question,
        'options': options
            .map((o) => {'id': o.id, 'text': o.text, 'voteCount': o.voteCount})
            .toList(),
        'status': status.value,
        'createdBy': createdBy,
        'createdAt': FirestoreConverters.fromDate(createdAt),
        'closesAt': FirestoreConverters.fromDate(closesAt),
      };
}

/// Data-layer DTO for `polls/{pollId}/votes/{uid}`.
class PollVoteModel extends PollVoteEntity {
  const PollVoteModel({
    required super.uid,
    required super.pollId,
    required super.optionId,
    required super.createdAt,
  });

  factory PollVoteModel.fromJson(
    Map<String, dynamic> json, {
    required String uid,
    required String pollId,
  }) {
    return PollVoteModel(
      uid: uid,
      pollId: pollId,
      optionId: json['optionId']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory PollVoteModel.fromEntity(PollVoteEntity entity) {
    return PollVoteModel(
      uid: entity.uid,
      pollId: entity.pollId,
      optionId: entity.optionId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
