// Re-export shim: `users`/`apartment_requests`/`apartments` are 1:1
// Firestore document mirrors, so their canonical entities live in
// `lib/core/models/` (single source of truth). See `lib/core/models/README.md`.
export '../../../../core/models/user_entity.dart';
export '../../../../core/models/apartment_request_entity.dart';
export '../../../../core/models/apartment_entity.dart';

/// Feature-local aggregate (not a `core/models` entity — it's a computed
/// view, not a 1:1 document mirror): a resident's lightweight activity
/// summary for the Resident Detail screen (§7.5.3).
class ResidentActivitySummaryEntity {
  const ResidentActivitySummaryEntity({
    required this.postCount,
    required this.commentCount,
    required this.reactionCount,
  });

  final int postCount;
  final int commentCount;
  final int reactionCount;
}
