# Announcements — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.7
**Arcle module:** `lib/features/announcements/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

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
- [ ] Replace the placeholder `announcements_screen.dart` (compiles against the real `AnnouncementsBloc`/`AnnouncementsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener on `announcements` — `WatchAnnouncementsUseCase` → `AnnouncementsFirestoreSource.watchAnnouncements` (ordered `createdAt desc`)
- [x] Create / edit / delete `announcements/{id}`: `title`, `body`, `createdBy`, `createdAt` — `Create`/`Update`/`DeleteAnnouncementUseCase`; `createdBy` is supplied by the caller (bloc), not read from session state inside the repository
- [x] On create, batched write of one `notifications` doc per resident in the building (`category: "announcement"`), chunked if resident count ever exceeds a single batch's 500-write limit — `AnnouncementsFirestoreSource.createAnnouncement` queries `users where buildingId==X` for recipient uids, then uses `FirestoreService.writeInChunks` (same chunking pattern as `BuildingsFirestoreSource.generateApartments`)

### Architecture notes

- Uses `AnnouncementEntity` directly from `core/models/` (1:1 document mirror) — same pattern as Buildings/Apartments; `domain/entity` and `data/model` are re-export shims.
- `data/source/announcements_remote_source.dart` (`AnnouncementsRemoteSource` / `AnnouncementsFirestoreSource`) is the only file a future backend swap touches.
- The announcement doc is created first, then the resident fan-out runs as a second step (not the same batch) — a fan-out failure never leaves the announcement itself missing; it's a best-effort broadcast, not part of the announcement's atomicity contract. Edit/delete deliberately do **not** re-fan-out notifications — the doc only specifies notification creation on announcement *create*.
