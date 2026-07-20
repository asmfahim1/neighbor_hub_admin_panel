// No feature-local model: `BuildingEntity` (from `core/models/`) is used
// directly end-to-end (Firestore doc <-> entity), since it already tolerates
// the Firestore wire format via `FirestoreConverters`. See
// `lib/core/models/README.md` for why Model and Entity are collapsed.
export '../../domain/entity/buildings_entity.dart';
