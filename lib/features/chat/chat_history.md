# Chat — History

| Date | Event | Details |
|---|---|---|
| 2026-07-20 | Feature scaffolded | Generated via `arcle feature chat` (data/domain/presentation layers, routing, DI wiring). |
| 2026-07-20 | Plan drafted | `chat_plan.md` created from `docs/admen_web_app_ui_functionality.md` §7.10–§7.10.1, split into separate **UI** and **Firebase Connection** task sections. No implementation done yet. |
| 2026-07-20 | Data/domain/presentation implemented | `ChatRemoteSource`/`ChatFirestoreSource` (conversation-list watch, per-conversation message watch, start-or-resume via deterministic conversation id, send message as a `WriteBatch` + best-effort recipient notification), `ChatRepositoryImpl`, 4 usecases, `ChatBloc` managing two independent stream subscriptions (conversation list + open conversation's messages). Presence/online-status left unimplemented (no schema field exists). Placeholder UI patched only enough to compile. `flutter analyze lib/features/chat` clean (0 errors) for this feature. |
