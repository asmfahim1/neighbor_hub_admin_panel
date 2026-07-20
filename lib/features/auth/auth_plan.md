# Auth — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.1
**Arcle module:** `lib/features/auth/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Sign-in + role gate. The Admin App/Web Portal is only for accounts with
`role == "admin"`. There is no self-service "become the first admin" path —
the first admin is bootstrapped manually in the Firebase Console
(`06_FIREBASE_SECURITY.md` §2.1).

## Screens (App + Web, same IA)

- Sign In (Email/Password, Google)
- Session gate (role check, shown while resolving auth state)
- Blocked-access state for a signed-in non-admin account

## UI Tasks

- [ ] Sign-in screen: email/password fields + Google sign-in button + Apple sign-in button (responsive: centered single column on phone, centered card on web/desktop)
- [ ] Form validation + inline error copy (human-readable, not raw Firebase error strings)
- [ ] Session-gate loading state while role is being resolved after sign-in
- [ ] Blocked-access screen: "This app is for building administrators" with sign-out action
- [x] Wire `AppRoutes.initialRoute` / router to land here first (already set as the app's initial route)
- [ ] Replace the placeholder `auth_screen.dart`/`auth_card.dart` (compiles against the real `AuthBloc`/`AuthState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Firebase Auth: email/password sign-in — `FirebaseAuthService.signInWithEmailAndPassword`
- [x] Firebase Auth: Google sign-in provider — `FirebaseAuthService.signInWithGoogle`
- [x] Firebase Auth: Apple sign-in provider — `FirebaseAuthService.signInWithApple` (nonce/SHA-256 handled)
- [x] After sign-in, read `users/{uid}/private/account.role` — `AuthFirestoreSource.fetchUserProfile`/`fetchPrivateAccount`
- [x] If `role != "admin"`, block entry and sign the user back out — `AuthRepositoryImpl._resolveSession`
- [x] If `role == "admin"`, populate `CurrentSession` (uid/buildingId/role) so every other feature can building-scope its queries — routing into the Dashboard is a router/UI concern, left for the UI pass
- [x] Rely on Firebase Auth's own session persistence — no custom token handling (`SessionManager`/`DioClient` untouched, reserved for a future REST backend)
- [x] Sign-out action (also used from Profile §7.12) — `SignOutUseCase` / `AuthRepositoryImpl.signOut`
- [x] Bonus: best-effort FCM token registration to `users/{uid}/private/account.fcmToken` on successful sign-in (`AuthFirestoreSource.registerFcmTokenSilently`), never blocking sign-in on failure

### Architecture notes (for the other 11 features to mirror)

- `domain/repository/auth_repository.dart` — abstract, returns `Result<AuthSessionEntity>` / `Stream<AuthSessionEntity?>`. Zero Firebase types leak past this boundary.
- `data/source/auth_remote_source.dart` — `AuthRemoteSource` abstract class + `AuthFirestoreSource implements AuthRemoteSource` (`@LazySingleton(as: AuthRemoteSource)`). **This is the only file that would need a sibling `AuthApiSource` when a custom backend arrives** — nothing else in this feature changes.
- `domain/entity/auth_entity.dart` (`AuthSessionEntity`) is feature-local, not a `core/models` entity — it's a composed session view, not a 1:1 Firestore document mirror. Compare with Buildings/Apartments, which use `core/models` entities directly since those *are* 1:1 document mirrors.
- `core/firebase/current_session.dart` (`CurrentSession`) is populated here and read by every other feature for `buildingId` scoping.

## Notes

- No rule changes needed for this feature.
- Depends on `users/{uid}/private/account.role` already existing per `05_FIRESTORE_DATABASE.md`.
