// Re-export shim: `announcements/{announcementId}` is a 1:1 Firestore
// document mirror, so its canonical entity lives in `lib/core/models/`
// (single source of truth). See `lib/core/models/README.md`.
export '../../../../core/models/announcement_entity.dart';
