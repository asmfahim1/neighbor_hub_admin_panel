import 'package:equatable/equatable.dart';

import '../../../../core/models/models.dart';

enum ModerationStatus { initial, loading, loaded, mutating, failure }

class ModerationState extends Equatable {
  const ModerationState({
    this.status = ModerationStatus.initial,
    this.feed = const [],
    this.openPostId,
    this.comments = const [],
    this.realAuthorUid,
    this.message,
  });

  final ModerationStatus status;
  final List<PostEntity> feed;

  /// The post whose comment thread is currently open, if any.
  final String? openPostId;
  final List<CommentEntity> comments;

  /// Resolved via `post_authorship/{postId}` for [openPostId] (or whichever
  /// post a reveal was last requested for) — always the true author.
  final String? realAuthorUid;

  final String? message;

  ModerationState copyWith({
    ModerationStatus? status,
    List<PostEntity>? feed,
    String? openPostId,
    bool clearOpenPostId = false,
    List<CommentEntity>? comments,
    String? realAuthorUid,
    bool clearRealAuthorUid = false,
    String? message,
    bool clearMessage = false,
  }) {
    return ModerationState(
      status: status ?? this.status,
      feed: feed ?? this.feed,
      openPostId: clearOpenPostId ? null : (openPostId ?? this.openPostId),
      comments: clearOpenPostId ? const [] : (comments ?? this.comments),
      realAuthorUid: clearRealAuthorUid ? null : (realAuthorUid ?? this.realAuthorUid),
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props =>
      [status, feed, openPostId, comments, realAuthorUid, message];
}
