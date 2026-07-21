import 'package:equatable/equatable.dart';

import '../constants/notification_category.dart';

/// Mirrors `notifications/{notificationId}` — `05_FIRESTORE_DATABASE.md` §3.13.
/// Written directly by clients (no Cloud Function) — zero-cost notification design.
///
/// Pure domain object — no Firestore/JSON knowledge. See [NotificationModel]
/// (`notification_model.dart`) for parsing/serialization.
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.recipientUid,
    required this.buildingId,
    required this.category,
    required this.title,
    required this.body,
    this.relatedPostId,
    this.relatedConversationId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String recipientUid;
  final String buildingId;
  final NotificationCategory category;
  final String title;
  final String body;
  final String? relatedPostId;
  final String? relatedConversationId;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        recipientUid: recipientUid,
        buildingId: buildingId,
        category: category,
        title: title,
        body: body,
        relatedPostId: relatedPostId,
        relatedConversationId: relatedConversationId,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        recipientUid,
        buildingId,
        category,
        title,
        body,
        relatedPostId,
        relatedConversationId,
        isRead,
        createdAt,
      ];
}
