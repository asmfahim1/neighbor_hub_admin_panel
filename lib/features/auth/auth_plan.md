# Auth — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.1
**Arcle module:** `lib/features/auth/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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
- [ ] Wire `AppRoutes.initialRoute` / router to land here first (already set as the app's initial route)

## Firebase Connection Tasks

- [ ] Firebase Auth: email/password sign-in
- [ ] Firebase Auth: Google sign-in provider
- [ ] Firebase Auth: Apple sign-in provider
- [ ] After sign-in, read `users/{uid}/private/account.role`
- [ ] If `role != "admin"`, block entry and sign the user back out
- [ ] If `role == "admin"`, route into the Dashboard
- [ ] Rely on Firebase Auth's own session persistence — no custom token handling
- [ ] Sign-out action (also used from Profile §7.12)

## Notes

- No rule changes needed for this feature.
- Depends on `users/{uid}/private/account.role` already existing per `05_FIRESTORE_DATABASE.md`.
