# Models

Canonical, framework-agnostic data classes mirroring every Firestore
document shape in `docs/05_FIRESTORE_DATABASE.md`, field-for-field. This is
the **single source of truth** for field names — every feature's domain and
data layer imports from here rather than declaring its own duplicate entity,
so the Admin App and the future Resident App can never drift.

## Why these double as both "Entity" and "Model"

In a typical Clean Architecture split, `data/model` (DTO) and
`domain/entity` are distinct classes with a mapping step between them. Here
they're deliberately collapsed into one class per document type, because:

- There is exactly one data source shape to adapt from (Firestore's
  `Map<String, dynamic>` documents) — a mapping layer with no divergent
  concerns to justify it is just boilerplate.
- The project's own architecture doc (`admen_web_app_ui_functionality.md`
  §3) explicitly calls for one shared model reused by both apps.
- `fromJson`/`toJson` are the only place any storage-format detail leaks in
  (via `FirestoreConverters`, which already tolerates a Firestore
  `Timestamp`, a plain `DateTime`, or an ISO-8601 string) — so swapping the
  backend later never requires touching a class in this folder, only the
  `data/source` remote source that calls the new endpoint.

Each feature's own `domain/entity/x_entity.dart` and `data/model/x_model.dart`
are kept as re-export shims pointing back here (see each feature's file) so
the arcle-scaffolded folder layout stays meaningful without duplicating the
class.

Reusable as-is in the future Resident App — copy this folder over first,
alongside `core/firebase/` and `core/constants/`.
