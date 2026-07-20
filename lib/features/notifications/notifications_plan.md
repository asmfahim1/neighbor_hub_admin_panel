# Notifications — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.11
**Arcle module:** `lib/features/notifications/` (data/domain/presentation, BLoC)

> Not to be confused with `lib/core/notifications/` — that is the shared,
> copyable local-notification plumbing (`flutter_local_notifications` wrapper).
> This feature is the admin-facing in-app inbox UI/state built on top of it.

**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

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
- [ ] Replace the placeholder `notifications_screen.dart` (compiles against the real `NotificationsBloc`/`NotificationsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener: `notifications where recipientUid == myUid` — `WatchNotificationsInboxUseCase` → `NotificationsFirestoreSource.watchInbox` (ordered `createdAt desc`; `recipientUid` supplied by the bloc, not read from session state inside the repository)
- [x] Drive local notification (via `flutter_local_notifications`, `lib/core/notifications/`) when a new doc arrives while the app is alive — `NotificationsFirestoreSource.watchInbox` inspects `QuerySnapshot.docChanges()` and calls `NotificationService.show(...)` only for genuinely new (`DocumentChangeType.added`) docs after the listener's first snapshot — pre-existing notifications never fire on app start
- [x] Mark-read write back to the `notifications` doc — `MarkNotificationAsReadUseCase` (`isRead → true`)
- [x] Categories relevant to admin: `chat` (new message) — category filtering is a client-side filter over the fetched list (`NotificationsState.visibleNotifications`), not a second Firestore query; no `(recipientUid, category, createdAt)` composite index is declared in `05_FIRESTORE_DATABASE.md` §5, so this deliberately avoids needing one
- [x] Explicitly out of scope: delivery when the app is fully killed — confirmed, not attempted

### Architecture notes

- Uses `NotificationEntity` directly from `core/models/` (1:1 document mirror) — `domain/entity` and `data/model` are re-export shims, same pattern as Apartments.
- `data/source/notifications_remote_source.dart` (`NotificationsRemoteSource` / `NotificationsFirestoreSource`) is the only file a future backend swap touches.
- This feature is distinct from `lib/core/notifications/` (`NotificationService`, `PushNotificationService`), which was NOT modified — this feature's `NotificationsFirestoreSource` *consumes* `NotificationService.show(...)` as a dependency, it doesn't own local-notification plumbing itself.
