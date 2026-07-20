/// Mirrors `notifications/{notificationId}.category` in `05_FIRESTORE_DATABASE.md` §3.13.
enum NotificationCategory {
  announcement,
  chat,
  reaction,
  comment,
  poll;

  String get value => switch (this) {
        NotificationCategory.announcement => 'announcement',
        NotificationCategory.chat => 'chat',
        NotificationCategory.reaction => 'reaction',
        NotificationCategory.comment => 'comment',
        NotificationCategory.poll => 'poll',
      };

  static NotificationCategory fromValue(String? value) => switch (value) {
        'chat' => NotificationCategory.chat,
        'reaction' => NotificationCategory.reaction,
        'comment' => NotificationCategory.comment,
        'poll' => NotificationCategory.poll,
        _ => NotificationCategory.announcement,
      };
}
