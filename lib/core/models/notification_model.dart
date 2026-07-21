import 'notification_entity.dart';
import '../constants/notification_category.dart';
import '../firebase/firestore_converters.dart';

/// Data-layer DTO for `notifications/{notificationId}`. See
/// `lib/core/models/README.md` for why Model extends Entity.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientUid,
    required super.buildingId,
    required super.category,
    required super.title,
    required super.body,
    super.relatedPostId,
    super.relatedConversationId,
    required super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return NotificationModel(
      id: id,
      recipientUid: json['recipientUid']?.toString() ?? '',
      buildingId: json['buildingId']?.toString() ?? '',
      category: NotificationCategory.fromValue(json['category']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      relatedPostId: json['relatedPostId']?.toString(),
      relatedConversationId: json['relatedConversationId']?.toString(),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: FirestoreConverters.toDateOrNow(json['createdAt']),
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientUid: entity.recipientUid,
      buildingId: entity.buildingId,
      category: entity.category,
      title: entity.title,
      body: entity.body,
      relatedPostId: entity.relatedPostId,
      relatedConversationId: entity.relatedConversationId,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipientUid': recipientUid,
        'buildingId': buildingId,
        'category': category.value,
        'title': title,
        'body': body,
        'relatedPostId': relatedPostId,
        'relatedConversationId': relatedConversationId,
        'isRead': isRead,
        'createdAt': FirestoreConverters.fromDate(createdAt),
      };
}
