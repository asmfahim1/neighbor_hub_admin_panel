# Apartments — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.4
**Arcle module:** `lib/features/apartments/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

CRUD + status management for `apartments`. `occupied` is not a free toggle —
it only happens through the Residents approval batch (§7.5.1); the admin can
freely toggle between `vacant` and `blocked` (maintenance) manually.

## Screens

- Apartments List — web: searchable/filterable table with inline status edit; app: grouped-by-floor cards
- Apartment Detail — create/edit sheet or page

## UI Tasks

- [ ] Apartments List (table on web, floor-grouped cards on app)
- [ ] Search/filter by floor, status, number
- [ ] Apartment Detail create/edit form: `number`, `floor`, `description`
- [ ] Status control: `vacant` ↔ `blocked` freely togglable; "Occupied" is disabled/hidden as a manual option
- [ ] When `status == "occupied"`, display resolved `primaryResidentUid` → `users/{uid}.displayName`
- [ ] Confirm dialog for delete apartment
- [ ] Empty state: "No apartments yet" → CTA into Buildings bulk generation
- [ ] Replace the placeholder `apartments_screen.dart` (compiles against the real `ApartmentsBloc`/`ApartmentsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener on `apartments where buildingId == X` — `WatchApartmentsUseCase` → `ApartmentsFirestoreSource.watchApartments`
- [x] Create / update / delete an `apartments` doc — `Create`/`Update`/`DeleteApartmentUseCase`
- [x] Write `vacant` ↔ `blocked` status changes directly (`updatedAt` bump) — `SetApartmentStatusUseCase`
- [x] Never write `status: "occupied"` from this feature — enforced in `ApartmentsRepositoryImpl.setStatus`, which rejects `occupied` with a `ValidationFailure` before it ever reaches Firestore (that only happens via the Residents approval `WriteBatch`, §7.5.1)
- [x] Resolve `primaryResidentUid` → `users/{uid}.displayName` for occupied apartments (read join) — `ResolvePrimaryResidentUseCase`

### Architecture notes

- Uses `ApartmentEntity` directly from `core/models/` (1:1 document mirror) — same pattern as Buildings.
- `data/source/apartments_remote_source.dart` (`ApartmentsRemoteSource` / `ApartmentsFirestoreSource`) is the only file a future backend swap touches.
- Serves as the "collection CRUD + realtime list + guarded status transition" exemplar (Buildings covers single-doc + bulk batch; Dashboard covers read-only multi-collection aggregation).
