// Re-export shim: `polls/{pollId}` and `polls/{pollId}/votes/{uid}` are 1:1
// Firestore document mirrors, so their canonical entities live in
// `lib/core/models/` (single source of truth). See `lib/core/models/README.md`.
export '../../../../core/models/poll_entity.dart';
