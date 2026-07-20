# Announcements — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.7
**Arcle module:** `lib/features/announcements/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

## Overview

Always attributed to "Building Management," never anonymous. Creating an
announcement fans out a `notifications` doc to every resident.

## Screens

- Announcement list
- Composer (create/edit)

## UI Tasks

- [ ] Announcement list (title, body preview, createdAt)
- [ ] Composer form (create/edit): `title`, `body`
- [ ] Confirm dialog for delete
- [ ] Attribution always shown as "Building Management"

## Firebase Connection Tasks

- [ ] Realtime listener on `announcements`
- [ ] Create / edit / delete `announcements/{id}`: `title`, `body`, `createdBy`, `createdAt`
- [ ] On create, batched write of one `notifications` doc per resident in the building (`category: "announcement"`), chunked if resident count ever exceeds a single batch's 500-write limit (not a concern at ~100 residents)
