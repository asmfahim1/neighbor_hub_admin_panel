# Auth — History

| Date | Event | Details |
|---|---|---|
| 2026-07-20 | Feature scaffolded | Generated via `arcle feature auth` (data/domain/presentation layers, routing, DI wiring). Replaced the removed `demo` feature's `AuthBloc`/login screen as the app's real auth module. |
| 2026-07-20 | Plan drafted | `auth_plan.md` created from `docs/admen_web_app_ui_functionality.md` §7.1, split into separate **UI** and **Firebase Connection** task sections. No implementation done yet. |
| 2026-07-20 | Data/domain/presentation implemented | Built `FirebaseAuthService`/`FirestoreService`/`CurrentSession` (`lib/core/firebase/`) as the shared foundation, then wired Auth on top: `AuthRemoteSource`/`AuthFirestoreSource` (swappable endpoint boundary), `AuthRepositoryImpl` (role-gate enforcement + `CurrentSession` population + best-effort FCM token registration), 6 usecases (watch/sign-in email/google/apple/reset/sign-out), and a stream-driven `AuthBloc`. Placeholder UI files patched only enough to compile against the new state shape — no real UI/UX applied yet. `flutter analyze` clean (0 errors) for this feature. |
