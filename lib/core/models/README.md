# Models

Canonical, framework-agnostic data classes mirroring every Firestore
document shape in `docs/05_FIRESTORE_DATABASE.md`, field-for-field. This is
the **single source of truth** for field names — every feature's domain and
data layer imports from here rather than declaring its own duplicate entity,
so the Admin App and the future Resident App can never drift.

## Entity vs. Model — properly separated

Each document type has **two** classes, in two files, following standard
Clean Architecture layering:

- **`x_entity.dart`** — the domain `XEntity`. Pure fields, `copyWith`, and
  business-logic getters (e.g. `PollEntity.isExpired`,
  `UserEntity.isPrimaryResident`). Zero knowledge of Firestore, JSON, or any
  storage format. This is what `domain/`, `presentation/`, and repository
  interfaces reference.
- **`x_model.dart`** — the data-layer `XModel extends XEntity`. The *only*
  place `fromJson`/`toJson`/`fromEntity` exist for that document type, via
  `FirestoreConverters` (which already tolerates a Firestore `Timestamp`, a
  plain `DateTime`, or an ISO-8601 string). Used exclusively inside
  `data/source/*_remote_source.dart` files:
  - **Reading:** `XModel.fromJson(doc.data(), id: doc.id)` — returns an
    `XModel`, which satisfies `XEntity` wherever the domain layer expects it
    (Liskov substitution) without the domain layer ever importing `XModel`.
  - **Writing:** `XModel.fromEntity(entityFromCaller).toJson()` — wraps a
    plain entity (e.g. one a bloc/usecase constructed) just long enough to
    serialize it.

Import `models.dart` (entities) from `domain/`/`presentation/`/repository
implementations. Import `data_models.dart` (models) only from
`data/source/*_remote_source.dart` files — never from anywhere else.

Each feature's own `domain/entity/x_entity.dart` and `data/model/x_model.dart`
are kept as re-export shims pointing back here (see each feature's file) so
the arcle-scaffolded folder layout stays meaningful without duplicating the
class, and so a future backend swap only ever touches that feature's
`data/source/*_remote_source.dart`.

## Why the Model lives in `core/`, not per-feature

Several entities are read by more than one feature (e.g. `UserEntity` by
Apartments, Residents, and Profile). Putting `XModel` in `core/models/`
alongside `XEntity` — rather than re-declaring an identical parsing class in
every feature that touches it — keeps parsing logic defined exactly once,
consistent with this folder's whole reason for existing (single source of
truth, shared by the future Resident App too).

Reusable as-is in the future Resident App — copy this folder over first,
alongside `core/firebase/` and `core/constants/`.
