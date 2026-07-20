import 'package:equatable/equatable.dart';

import '../../../../core/models/models.dart';

abstract class ModerationEvent extends Equatable {
  const ModerationEvent();

  @override
  List<Object?> get props => [];
}

class ModerationFeedWatchStarted extends ModerationEvent {
  const ModerationFeedWatchStarted(this.buildingId);
  final String buildingId;

  @override
  List<Object?> get props => [buildingId];
}

/// Internal — emitted by the feed's own stream subscription.
class ModerationFeedUpdated extends ModerationEvent {
  const ModerationFeedUpdated(this.posts);
  final List<PostEntity> posts;

  @override
  List<Object?> get props => [posts];
}

/// Opens a post's comment thread — starts a dedicated comments listener.
class PostThreadOpened extends ModerationEvent {
  const PostThreadOpened(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

/// Internal — emitted by the open thread's own stream subscription.
class ModerationCommentsUpdated extends ModerationEvent {
  const ModerationCommentsUpdated(this.comments);
  final List<CommentEntity> comments;

  @override
  List<Object?> get props => [comments];
}

class PostThreadClosed extends ModerationEvent {
  const PostThreadClosed();
}

class RealAuthorRequested extends ModerationEvent {
  const RealAuthorRequested(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

class PostDeleteRequested extends ModerationEvent {
  const PostDeleteRequested(this.postId);
  final String postId;

  @override
  List<Object?> get props => [postId];
}

class CommentDeleteRequested extends ModerationEvent {
  const CommentDeleteRequested(this.postId, this.commentId);
  final String postId;
  final String commentId;

  @override
  List<Object?> get props => [postId, commentId];
}

class PostLockToggled extends ModerationEvent {
  const PostLockToggled(this.postId, this.isLocked);
  final String postId;
  final bool isLocked;

  @override
  List<Object?> get props => [postId, isLocked];
}

class PostPinToggled extends ModerationEvent {
  const PostPinToggled(this.postId, this.isPinned);
  final String postId;
  final bool isPinned;

  @override
  List<Object?> get props => [postId, isPinned];
}
