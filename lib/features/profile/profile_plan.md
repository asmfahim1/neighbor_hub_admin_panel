# Profile — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.12
**Arcle module:** `lib/features/profile/` (data/domain/presentation, BLoC)

> Distinct from the pre-existing `lib/features/settings/` (app-level theme/locale
> preference cubit) — this feature owns the admin's own profile data and is
> the entry point into the Transfer Admin Role flow. It may end up composing
> `settings/` rather than duplicating theme-toggle logic; decide during
> implementation.

**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Update own `users/{uid}`: `displayName`, `photoUrl` (self-update path, unaffected by any admin-only rule carve-outs)
- [ ] Sign out via Firebase Auth
- [ ] No direct writes here for Transfer Admin Role — that batch lives in Residents §7.5.4; this screen only opens the picker
