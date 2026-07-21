import 'package:equatable/equatable.dart';

import '../constants/post_category.dart';

/// Mirrors `posts/{postId}` — `05_FIRESTORE_DATABASE.md` §3.5.
///
/// `authorUid` is null when the post is anonymous — the real author is only
/// ever resolved via [PostAuthorshipEntity] (admin-only). Pure domain
/// object — no Firestore/JSON knowledge. See [PostModel] (`post_model.dart`)
/// for parsing/serialization.
class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.buildingId,
    this.authorUid,
    required this.isAnonymous,
    required this.category,
    required this.text,
    required this.isPinned,
    required this.isLocked,
    required this.reactionCount,
    required this.commentCount,
    required this.bookmarkCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String buildingId;
  final String? authorUid;
  final bool isAnonymous;
  final PostCategory category;
  final String text;
  final bool isPinned;
  final bool isLocked;
  final int reactionCount;
  final int commentCount;
  final int bookmarkCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostEntity copyWith({
    bool? isPinned,
    bool? isLocked,
    int? reactionCount,
    int? commentCount,
    int? bookmarkCount,
    DateTime? updatedAt,
  }) {
    return PostEntity(
      id: id,
      buildingId: buildingId,
      authorUid: authorUid,
      isAnonymous: isAnonymous,
      category: category,
      text: text,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      reactionCount: reactionCount ?? this.reactionCount,
      commentCount: commentCount ?? this.commentCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        buildingId,
        authorUid,
        isAnonymous,
        category,
        text,
        isPinned,
        isLocked,
        reactionCount,
        commentCount,
        bookmarkCount,
        createdAt,
        updatedAt,
      ];
}

/// Mirrors `post_authorship/{postId}` (admin-only collection) —
/// `05_FIRESTORE_DATABASE.md` §3.6. Always holds the real author, regardless
/// of `isAnonymous` on the public post. Pure domain object — see
/// [PostAuthorshipModel] for parsing/serialization.
class PostAuthorshipEntity extends Equatable {
  const PostAuthorshipEntity({
    required this.postId,
    required this.authorUid,
    required this.isAnonymous,
    required this.buildingId,
    required this.createdAt,
  });

  final String postId;
  final String authorUid;
  final bool isAnonymous;
  final String buildingId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [postId, authorUid, isAnonymous, buildingId, createdAt];
}

/// Mirrors `posts/{postId}/comments/{commentId}` — `05_FIRESTORE_DATABASE.md` §3.8.
/// Comments are always attributed — anonymity applies to posts only. Pure
/// domain object — see [CommentModel] for parsing/serialization.
class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.postId,
    required this.authorUid,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String postId;
  final String authorUid;
  final String text;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, postId, authorUid, text, createdAt];
}
