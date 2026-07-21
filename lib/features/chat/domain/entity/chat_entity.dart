// Re-export shim: `conversations/{id}` and `conversations/{id}/messages/{id}`
// are 1:1 Firestore document mirrors, so their canonical entities live in
// `lib/core/models/` (single source of truth). See `lib/core/models/README.md`.
export '../../../../core/models/conversation_entity.dart';
