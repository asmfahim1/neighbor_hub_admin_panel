# Apartments — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.4
**Arcle module:** `lib/features/apartments/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Realtime listener on `apartments where buildingId == X`
- [ ] Create / update / delete an `apartments` doc
- [ ] Write `vacant` ↔ `blocked` status changes directly (`updatedAt` bump)
- [ ] Never write `status: "occupied"` from this feature — that only happens via the Residents approval `WriteBatch` (§7.5.1)
- [ ] Resolve `primaryResidentUid` → `users/{uid}.displayName` for occupied apartments (read join)
