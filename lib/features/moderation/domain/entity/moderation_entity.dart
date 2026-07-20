// Re-export shim: `posts`, `post_authorship`, and `posts/{id}/comments` are
// 1:1 Firestore document mirrors, so their canonical entities live in
// `lib/core/models/` (single source of truth shared by every feature and the
// future Resident App). See `lib/core/models/README.md`.
export '../../../../core/models/post_entity.dart';
