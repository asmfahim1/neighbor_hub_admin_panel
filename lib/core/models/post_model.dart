import 'post_entity.dart';
import '../constants/post_category.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `posts/{postId}`. See `lib/core/models/README.md` for
/// why Model extends Entity.
class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.buildingId,
    super.authorUid,
    required super.isAnonymous,
    required super.category,
    required super.text,
    required super.isPinned,
    required super.isLocked,
    required super.reactionCount,
    required super.commentCount,
    required super.bookmarkCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return PostModel(
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

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      buildingId: entity.buildingId,
      authorUid: entity.authorUid,
      isAnonymous: entity.isAnonymous,
      category: entity.category,
      text: entity.text,
      isPinned: entity.isPinned,
      isLocked: entity.isLocked,
      reactionCount: entity.reactionCount,
      commentCount: entity.commentCount,
      bookmarkCount: entity.bookmarkCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
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
}

/// Data-layer DTO for `post_authorship/{postId}`.
class PostAuthorshipModel extends PostAuthorshipEntity {
  const PostAuthorshipModel({
    required super.postId,
    required super.authorUid,
    required super.isAnonymous,
    required super.buildingId,
    required super.createdAt,
  });

  factory PostAuthorshipModel.fromJson(
    Map<String, dynamic> json, {
    required String postId,
  }) {
    return PostAuthorshipModel(
      postId: postId,
      authorUid: json['authorUid']?.toString() ?? '',
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      buildingId: json['buildingId']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory PostAuthorshipModel.fromEntity(PostAuthorshipEntity entity) {
    return PostAuthorshipModel(
      postId: entity.postId,
      authorUid: entity.authorUid,
      isAnonymous: entity.isAnonymous,
      buildingId: entity.buildingId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorUid': authorUid,
        'isAnonymous': isAnonymous,
        'buildingId': buildingId,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}

/// Data-layer DTO for `posts/{postId}/comments/{commentId}`.
class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorUid,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromJson(
    Map<String, dynamic> json, {
    required String id,
    required String postId,
  }) {
    return CommentModel(
      id: id,
      postId: postId,
      authorUid: json['authorUid']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      postId: entity.postId,
      authorUid: entity.authorUid,
      text: entity.text,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorUid': authorUid,
        'text': text,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
