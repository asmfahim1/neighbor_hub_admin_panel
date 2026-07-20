# Notifications — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.11
**Arcle module:** `lib/features/notifications/` (data/domain/presentation, BLoC)

> Not to be confused with `lib/core/notifications/` — that is the shared,
> copyable local-notification plumbing (`flutter_local_notifications` wrapper).
> This feature is the admin-facing in-app inbox UI/state built on top of it.

**Status:** Scaffolded only — no business logic implemented yet.

## Overview

In-app notification inbox, plus a local system notification while the app
process is alive (foreground or backgrounded-but-alive). Delivery when the
app is fully killed is explicitly out of scope for Phase 1 (agreed, not a
bug).

## Screens

- Notification inbox (in-app)

## UI Tasks

- [ ] Notification inbox list, ordered `createdAt desc`
- [ ] Filter by `category`
- [ ] Mark-as-read interaction
- [ ] Empty state for no notifications

## Firebase Connection Tasks

- [ ] Realtime listener: `notifications where recipientUid == myUid`
- [ ] Drive local notification (via `flutter_local_notifications`, `lib/core/notifications/`) when a new doc arrives while the app is alive
- [ ] Mark-read write back to the `notifications` doc
- [ ] Categories relevant to admin: `chat` (new message) — the `apartment_requests` pending queue is a direct listener, not a `notifications` doc (see Residents §7.5.1)
- [ ] Explicitly out of scope: delivery when the app is fully killed
