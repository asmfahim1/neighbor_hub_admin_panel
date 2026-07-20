import 'package:equatable/equatable.dart';

import '../constants/post_category.dart';
import '../firebase/firestore_converters.dart';

/// Mirrors `posts/{postId}` — `05_FIRESTORE_DATABASE.md` §3.5.
///
/// `authorUid` is null when the post is anonymous — the real author is only
/// ever resolved via [PostAuthorshipEntity] (admin-only).
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

  factory PostEntity.fromJson(Map<String, dynamic> json, {required String id}) {
    return PostEntity(
      id: id,
      buildingId: json['buildingId']?.toString() ?? '',
      authorUid: json['authorUid']?.toString(),
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      category: PostCategory.fromValue(json['category']?.toString()),
      text: json['text']?.toString() ?? '',
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      bookmarkCount: (json['bookmarkCount'] as num?)?.toInt() ?? 0,
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
      updatedAt: FirestoreConverters.toDateOrNow(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'buildingId': buildingId,
        'authorUid': authorUid,
        'isAnonymous': isAnonymous,
        'category': category.valueOrNull,
        'text': text,
        'isPinned': isPinned,
        'isLocked': isLocked,
        'reactionCount': reactionCount,
        'commentCount': commentCount,
        'bookmarkCount': bookmarkCount,
        'createdAt': FirestoreConverters.fromDate(createdAt),
        'updatedAt': FirestoreConverters.fromDate(updatedAt),
      };

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
/// of `isAnonymous` on the public post.
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

  factory PostAuthorshipEntity.fromJson(
    Map<String, dynamic> json, {
    required String postId,
  }) {
    return PostAuthorshipEntity(
      postId: postId,
      authorUid: json['authorUid']?.toString() ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      buildingId: json['buildingId']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'authorUid': authorUid,
        'isAnonymous': isAnonymous,
        'buildingId': buildingId,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [postId, authorUid, isAnonymous, buildingId, createdAt];
}

/// Mirrors `posts/{postId}/comments/{commentId}` — `05_FIRESTORE_DATABASE.md` §3.8.
/// Comments are always attributed — anonymity applies to posts only.
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

  factory CommentEntity.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String postId,
  }) {
    return CommentEntity(
      id: id,
      postId: postId,
      authorUid: json['authorUid']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'authorUid': authorUid,
        'text': text,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };

  @override
  List<Object?> get props => [id, postId, authorUid, text, createdAt];
}
