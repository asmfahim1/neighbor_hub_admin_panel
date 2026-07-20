// Re-export shim: `buildings/{buildingId}` is a 1:1 Firestore document mirror,
// so its canonical entity lives in `lib/core/models/` (single source of
// truth shared by every feature and the future Resident App) rather than
// being duplicated here. See `lib/core/models/README.md`.
export '../../../../core/models/building_entity.dart';
