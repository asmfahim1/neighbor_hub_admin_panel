# Buildings — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.3, §6.1
**Arcle module:** `lib/features/buildings/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Building profile (single building per `buildingId`) plus, on Web only, bulk
apartment generation. Includes the `adminUid` field addendum (§6.1) — read-only
display here, only ever changed by the Transfer-Admin-Role flow (Residents §7.5.4).

## Screens

- Building Profile — app: single form screen; web: form + apartment-generation panel

## UI Tasks

- [ ] Building Profile form: `name`, `address`, `totalFloors`, `apartmentsPerFloor`
- [ ] `adminUid` shown read-only (not editable here)
- [ ] Validation: `totalFloors`/`apartmentsPerFloor` must be positive integers
- [ ] Warning dialog when changing floor/apartment counts after apartments already exist (would desync the Dashboard's floor breakdown)
- [ ] Bulk apartment-generation panel — **Web only**
- [ ] Confirmation before bulk-generating (irreversible-feeling bulk write)
- [ ] Replace the placeholder `buildings_screen.dart`/`buildings_card.dart` (compiles against the real `BuildingsBloc`/`BuildingsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Create/update `buildings/{buildingId}`: `name`, `address`, `totalFloors`, `apartmentsPerFloor` — `SaveBuildingUseCase` → `BuildingsRepositoryImpl.saveBuilding` (merge write, `adminUid` untouched)
- [x] Bulk apartment generation: given `totalFloors` × `apartmentsPerFloor`, write that many `apartments` docs via `WriteBatch`, chunked at the 500-write cap — `GenerateApartmentsUseCase` → `FirestoreService.writeInChunks` (450/chunk)
- [x] Each generated apartment defaults to `status: "vacant"`, `primaryResidentUid: null`, predictable floor-major numbering (`"{floor}-{unit}"`, e.g. `"1-01"`) — editable after generation via Apartments
- [x] Dedupe check before writing — `BuildingsFirestoreSource.generateApartments` reads existing `number`s for the building first and skips any that already exist
- [x] Realtime read of `buildings/{buildingId}` for the profile form and `adminUid` display — `WatchBuildingUseCase` → `BuildingsBloc` (`BuildingWatchStarted`)

### Architecture notes

- Uses `BuildingEntity` directly from `core/models/` — `domain/entity` and `data/model` are re-export shims (see `auth_plan.md`'s architecture notes for the general pattern; this is the "1:1 Firestore document" case, unlike Auth's composed session entity).
- `data/source/buildings_remote_source.dart` (`BuildingsRemoteSource` / `BuildingsFirestoreSource`) is the only file a future backend swap touches.
