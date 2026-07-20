# Buildings — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.3, §6.1
**Arcle module:** `lib/features/buildings/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Create/update `buildings/{buildingId}`: `name`, `address`, `totalFloors`, `apartmentsPerFloor`
- [ ] Bulk apartment generation: given `totalFloors` × `apartmentsPerFloor`, write that many `apartments` docs via `WriteBatch`, chunked at the 500-write cap
- [ ] Each generated apartment defaults to `status: "vacant"`, `primaryResidentUid: null`, predictable floor-major numbering (editable after generation)
- [ ] Dedupe check before writing — never regenerate apartments that already exist for a floor/number combo
- [ ] Realtime read of `buildings/{buildingId}` for the profile form and `adminUid` display
