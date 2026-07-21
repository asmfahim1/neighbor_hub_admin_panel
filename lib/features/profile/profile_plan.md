# Profile — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.12
**Arcle module:** `lib/features/profile/` (data/domain/presentation, BLoC)

> Distinct from the pre-existing `lib/features/settings/` (app-level theme/locale
> preference cubit) — this feature owns the admin's own profile data and is
> the entry point into the Transfer Admin Role flow. It may end up composing
> `settings/` rather than duplicating theme-toggle logic; decide during
> implementation.

**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Self-service profile management for the signed-in admin, plus the entry
point into the single-admin handoff flow (Residents §7.5.4).

## Screens

- Profile form
- Theme toggle (light/dark/system) — see note above re: `settings/` reuse
- "Transfer Admin Role" entry point

## UI Tasks

- [ ] Profile form: `displayName`, `photoUrl`
- [ ] Theme toggle control (reuse/compose `AppSettingsCubit` from `settings/` rather than duplicating)
- [ ] Sign-out action
- [ ] "Transfer Admin Role" entry point, opening the Residents §7.5.4 picker
- [ ] Replace the placeholder `profile_screen.dart` (compiles against the real `ProfileBloc`/`ProfileState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Update own `users/{uid}`: `displayName`, `photoUrl` (self-update path, unaffected by any admin-only rule carve-outs) — `UpdateOwnProfileUseCase` → `ProfileFirestoreSource.updateOwnProfile` (partial `update()`, only the two fields ever touched here — `buildingId`/`apartmentId`/`authProvider`/`createdAt` are never written from this path)
- [x] Sign out via Firebase Auth — `ProfileSignOutUseCase` → `ProfileFirestoreSource.signOut`, calling `FirebaseAuthService.signOut()` directly (not the Auth feature's repository — see Architecture notes)
- [x] No direct writes here for Transfer Admin Role — confirmed, that batch lives entirely in Residents §7.5.4; this feature has no such method
- [x] Bonus: realtime watch of the admin's own `users/{uid}` doc — `WatchOwnProfileUseCase` → `ProfileFirestoreSource.watchOwnProfile`

### Architecture notes

- Uses `UserEntity` directly from `core/models/` (1:1 document mirror) — `domain/entity` is a re-export shim, same pattern as Buildings.
- `data/source/profile_remote_source.dart` (`ProfileRemoteSource` / `ProfileFirestoreSource`) injects `FirestoreService` + `FirebaseAuthService` directly, mirroring `AuthFirestoreSource`'s shape — deliberately does **not** import the Auth feature's `domain`/`data` layers (illegal cross-feature coupling; features only ever share `core/`).
- Theme toggle is not duplicated — the plan explicitly defers to composing the existing `AppSettingsCubit` (`lib/features/settings/`) once the UI pass happens.
