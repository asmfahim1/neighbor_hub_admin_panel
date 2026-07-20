# Notifications — History

| Date | Event | Details |
|---|---|---|
| 2026-07-20 | Feature scaffolded | Generated via `arcle feature notifications` (data/domain/presentation layers, routing, DI wiring). Distinct from the pre-existing shared `lib/core/notifications/` local-notification plumbing. |
| 2026-07-20 | Plan drafted | `notifications_plan.md` created from `docs/admen_web_app_ui_functionality.md` §7.11, split into separate **UI** and **Firebase Connection** task sections. No implementation done yet. |
| 2026-07-20 | Data/domain/presentation implemented | `NotificationsRemoteSource`/`NotificationsFirestoreSource` (realtime inbox watch with `docChanges()`-based new-notification detection driving `NotificationService.show(...)`, mark-as-read), `NotificationsRepositoryImpl`, 2 usecases, stream-driven `NotificationsBloc` with a client-side category filter (`NotificationsState.visibleNotifications`). Placeholder UI patched only enough to compile. `flutter analyze lib/features/notifications` clean (0 errors) for this feature. |
