# Auth — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.1
**Arcle module:** `lib/features/auth/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase (see §"Firebase
Section"). UI implemented for web + mobile, wired to `AuthBloc`. Admin
sign-up now also supports Google/Apple, a dedicated `SplashScreen` gates
app start on auto-login, and the mobile/app layout bug (web split-pane
showing on a wide compiled-app window) is fixed.

**Template note:** this file follows `docs/16_FEATURE_PLAN_HISTORY_TEMPLATE.md`
— every other feature's plan file gets restructured to match the next time
that feature is touched.

## Overview

Sign-in + role gate. The Admin App/Web Portal is only for accounts with
`role == "admin"`.

**Revision (2026-07-21):** the original design assumed the first admin is
bootstrapped manually in the Firebase Console (`06_FIREBASE_SECURITY.md`
§2.1) — this no longer holds. The product now ships without a super-admin
able to do that console step for every deployment, so a **self-service
admin sign-up** ("Bootstrap-once" model) was added: exactly one person, the
first to complete the sign-up form, becomes the single building's admin;
after that, sign-up is permanently closed and any further admin changes
only happen via the existing Transfer Admin Role flow (Residents §7.5.4).
See Notes for the full decision record and rejected alternative
(multi-tenant, one building per sign-up).

## Screens (App + Web, same IA)

- Splash (full-screen brand moment + auto-login gate, shown once on app start)
- Sign In (Email/Password, Google, Apple)
- Sign Up (self-service admin bootstrap — building name/address, then either
  Google/Apple or admin display name, email, password)
- Session gate (role check, shown while resolving auth state)
- Blocked-access state for a signed-in non-admin account (collapsed into the
  same error-banner UI as any other sign-in failure — see UI Design Plan)

## UI Design Plan

**Responsive behavior:** one screen, two layouts, switched on
`Dimensions.isWeb` (`Dimensions.webBreakpoint`, 1024px), consistent with
`04_UI_UX_GUIDELINES.md` §11's "same IA, density/layout differs" rule.

- **Mobile (< 1024px):** single scrollable column. Brand mark + app name
  centered at the top, subtitle below, then the sign-in form directly on
  the scaffold background (no card chrome — simpler, more native-feeling
  on a phone), Google/Apple buttons below a divider, "for building
  administrators only" footnote at the bottom.
- **Web (≥ 1024px):** two-pane split. Left pane: full-height brand panel
  (gradient over `AppColors.brandNavyLight`/`brandNavyDark`, adapts with
  theme) with the brand mark, app name, and a one-line tagline. Right pane:
  centered white card (`Card` via the existing `CardTheme`), max width
  ~420, containing the identical sign-in form used on mobile.

**Shared widgets reused (`lib/core/common_widgets/`):** `CommonTextField`
(email/password), `CommonButton` (submit — has a built-in `isLoading`
state), `CommonDialog` (forgot-password prompt). New feature-local widgets:
`AuthBrandPanel` (logo + name + tagline, used in both layouts at different
sizes), `AuthErrorBanner` (inline failure message), `SignInForm` (the form
itself), `SocialSignInButtons` (Google/Apple).

**States designed for** (mapped 1:1 to `AuthStatus`):
- `unknown` / `authenticating` → centered `CommonLoader`.
- `unauthenticated` / `failure` → the sign-in layout; `failure` additionally
  shows `AuthErrorBanner` with `AuthState.message` above the form (this is
  also how the "blocked non-admin account" case reads — the bloc already
  collapses it into `failure` with a specific message, so no separate
  blocked-access screen was built; a dedicated one can be split out later
  if the design ever needs to visually distinguish it).
- `authenticated` → navigates away (`AppRoutes.dashboard`) via the
  `BlocConsumer` listener; nothing rendered here.

**Interactions:**
- Email/password validated client-side (`AppValidators.email`/`.password`)
  before dispatching `SignInWithEmailRequested` — avoids a round trip for
  obviously-invalid input.
- "Forgot password?" opens a `CommonDialog` with an email field; confirming
  dispatches `PasswordResetRequested(email)`.
- Google/Apple buttons dispatch `SignInWithGoogleRequested()` /
  `SignInWithAppleRequested()` directly — no extra form.
- Submit button reflects `AuthStatus.authenticating` via `CommonButton.isLoading`.

**StatefulWidget usage:** exactly one per screen — `SignInForm` (sign-in)
and `SignUpForm` (sign-up). Each owns its own `TextEditingController`s, a
`GlobalKey<FormState>`, and the password-obscure toggle, none of which the
Bloc should own (they're widget-lifecycle/ephemeral-UI concerns, not app
state) and a `TextEditingController` must be disposed by a `State`. Every
other widget (`AuthScreen`, `SignUpScreen`, `AuthBrandPanel`,
`AuthErrorBanner`, `SocialSignInButtons`, both screens' mobile/web layout
wrappers) is a `StatelessWidget` driven by `BlocBuilder`/`BlocConsumer`.

**Sign Up screen** mirrors Sign In's responsive layout exactly (same
`AuthBrandPanel`/`AuthErrorBanner`, same mobile-single-column /
web-split-pane structure) — see `sign_up_screen.dart`. Each screen links to
the other: Sign In has "New building? Register as admin" →
`AppRoutes.signUp`; Sign Up has "Already have an account? Sign in" →
`AppRoutes.auth`.

**`SignUpForm` — two sibling `Form`s, not one (2026-07-21):** building
name/address → Google/Apple buttons → "or continue with email" divider →
admin display name, email, password, confirm password (client-side match
check) → "Create account". Fields are split across `_buildingFormKey`
(building name/address only) and `_accountFormKey` (the rest) because
Google/Apple sign-up only needs the building fields — Flutter's
nested-`Form` semantics register a `FormField` with the *nearest* enclosing
`Form`, so there's no way for one outer `Form` to validate only a subset of
its own fields; two independent sibling `Form`s (each with its own
`GlobalKey<FormState>`) is what lets the social buttons call
`_buildingFormKey.currentState!.validate()` alone while "Create account"
validates both keys. Both forms use `AutovalidateMode.onUserInteraction`
(added after live testing surfaced that validation errors were sticking
around after the user fixed their input).

**Splash screen (`SplashScreen`, 2026-07-21):** the app's new initial
route (`AppRoutes.splash`) — a full-screen version of the web layout's
left brand panel (same gradient over `AppColors.brandNavyLight`/
`brandNavyDark`), logo scale-in, and the app name revealed letter-by-letter
via `AnimatedAppName` (the feature's third `StatefulWidget` — owns the
`AnimationController` driving the staggered per-character `Interval`
fade+slide). Doubles as the **auto-login gate**: `_SplashScreenState`
awaits `AuthBloc`'s stream for the first non-`unknown` status (or uses the
already-resolved state if the bloc got there before the splash even
mounted), races that against a minimum display duration (so the animation
is never skipped on an instant-resolve), then routes to
`AppRoutes.dashboard` (authenticated) or `AppRoutes.auth` (everything
else). This is genuinely provider-agnostic auto-login — it doesn't matter
whether the last sign-in was email/password, Google, or Apple, because
`AuthBloc.watchAuthState()` is driven entirely by `FirebaseAuth.authStateChanges()`,
which reflects Firebase's own persisted session regardless of which
provider created it. No new auto-login mechanism was built; the splash
screen only adds a presentable "waiting" moment in front of the
mechanism `AuthBloc` already had since day one (`AuthStarted` dispatched
once at bloc construction, per `auth_history.md`'s first data/domain entry).

**Mobile/app layout bug fixed (2026-07-21):** the web split-pane layout was
rendering on the compiled app (not just the browser) whenever its window
was wide — traced to `Dimensions.deviceType` gating purely on screen width,
so a wide desktop-app window satisfied the same `>= webBreakpoint` check a
browser tab would. Fixed at the source in `core/utils/dimensions.dart`:
`DeviceType.web` now requires **both** `kIsWeb` (a literal Flutter Web
build) **and** the width check — a compiled app window, however wide, now
falls through to the `tablet`/`mobile` density instead. No changes were
needed in `AuthScreen`/`SignUpScreen` themselves: their mobile layouts
already rendered exactly what was wanted (compact logo + name at the top,
no left-side panel) — the bug was purely in which layout branch got
selected, not in the mobile layout's own design.

## Firebase Section

- [x] Firebase Auth: email/password sign-in — `FirebaseAuthService.signInWithEmailAndPassword`
- [x] Firebase Auth: Google sign-in provider — `FirebaseAuthService.signInWithGoogle`
- [x] Firebase Auth: Apple sign-in provider — `FirebaseAuthService.signInWithApple` (nonce/SHA-256 handled)
- [x] After sign-in, read `users/{uid}/private/account.role` — `AuthFirestoreSource.fetchUserProfile`/`fetchPrivateAccount`
- [x] If `role != "admin"`, block entry and sign the user back out — `AuthRepositoryImpl._resolveSession`
- [x] If `role == "admin"`, populate `CurrentSession` (uid/buildingId/role) so every other feature can building-scope its queries
- [x] Rely on Firebase Auth's own session persistence — no custom token handling (`SessionManager`/`DioClient` untouched, reserved for a future REST backend)
- [x] Sign-out action (also used from Profile §7.12) — `SignOutUseCase` / `AuthRepositoryImpl.signOut`
- [x] Bonus: best-effort FCM token registration to `users/{uid}/private/account.fcmToken` on successful sign-in (`AuthFirestoreSource.registerFcmTokenSilently`), never blocking sign-in on failure
- [x] **Self-service admin sign-up** — `SignUpAsAdminUseCase` → `AuthRepositoryImpl.signUpAsAdmin`:
  1. `FirebaseAuthService.createUserWithEmailAndPassword` — new Firebase Auth account, signed in immediately
  2. `AuthFirestoreSource.bootstrapAdminAccount` — one `WriteBatch` creating `buildings/{singleBuildingId}` (`adminUid` = new uid), `users/{uid}` (`buildingId` already set, `apartmentId: null`), and `users/{uid}/private/account` (`role: "admin"`)
  3. Compensating cleanup: if step 2 fails (lost the race — someone else already claimed the building), `FirebaseAuthService.deleteCurrentUser()` removes the orphaned auth-only account so the email isn't stuck
- [x] `firestore.rules` updated: `isBootstrappingFirstAdmin`/`isBootstrappingAdminUserCreate`/`isBootstrappingAdminPrivateCreate`, each gated on `!exists(buildings/{singleBuildingId})` — permanently false for everyone once the first sign-up succeeds. Validated with `firebase deploy --only firestore:rules --dry-run` against the real project (compiled successfully) — **not yet deployed**, see Notes.
- [x] **Google/Apple admin sign-up** (2026-07-21) — `SignUpAsAdminWithGoogleUseCase`/`SignUpAsAdminWithAppleUseCase` → `AuthRepositoryImpl.signUpAsAdminWithGoogle`/`signUpAsAdminWithApple`, both funneling into a shared `_signUpWithProvider` helper:
  1. `AuthFirestoreSource.signInWithGoogleForBootstrap`/`signInWithAppleForBootstrap` — sign in via the existing `FirebaseAuthService.signInWithGoogle`/`signInWithApple`, but surface `AuthProviderIdentity` (`uid`/`email`/`displayName`) instead of just the uid, since `bootstrapAdminAccount` needs those fields and there's no separate form collecting them for this path.
  2. **"Already registered" guard:** unlike email/password sign-up, Firebase Auth happily signs in an *existing* Google/Apple identity rather than failing — so before bootstrapping, `fetchUserProfile(uid)` is checked; a non-null profile means this person should sign in instead, returned as `ValidationFailure('This account is already registered. Please sign in instead.')`.
  3. Otherwise proceeds exactly like email/password: `bootstrapAdminAccount` (now parameterized with `authProvider: AppAuthProvider.google`/`.apple` instead of a hardcoded `.password`), then `_resolveSession`.
  4. **No compensating delete on failure** here (unlike `signUpAsAdmin`'s `deleteCurrentAccount()`): the Google/Apple identity is persistent — the same uid is returned on every attempt for the same person — so a lost bootstrap race just means the next attempt naturally retries against the same uid. There's no orphaned-email problem the way a brand-new email/password account could leave behind.

## Backend API (Future)

Once a custom backend exists, `AuthApiSource implements AuthRemoteSource`
replaces `AuthFirestoreSource` — nothing in `domain/`, `data/repository/`,
or `presentation/` changes. Shapes below are the anticipated REST surface;
adjust field names to match whatever the backend team actually ships (the
only place that would need touching is `AuthApiSource` itself).

### Sign in with email/password
- **Method & path:** `POST /auth/sign-in`
- **Request body:**
  ```json
  { "email": "admin@example.com", "password": "••••••••" }
  ```
- **Response body:**
  ```json
  {
    "uid": "abc123",
    "accessToken": "...",
    "refreshToken": "...",
    "profile": { "displayName": "Jane Doe", "buildingId": "bldg_1", "apartmentId": null },
    "account": { "email": "admin@example.com", "role": "admin", "accountStatus": "active" }
  }
  ```
- **Errors:** `401` invalid credentials, `403` account disabled/removed.

### Self-service admin sign-up
- **Method & path:** `POST /auth/sign-up`
- **Request body:**
  ```json
  {
    "buildingName": "Sunrise Apartments",
    "buildingAddress": "123 Main St, Springfield",
    "displayName": "Jane Doe",
    "email": "admin@example.com",
    "password": "••••••••"
  }
  ```
- **Response body:** same shape as email/password sign-in (uid + tokens + profile + account).
- **Errors:** `409 Conflict` if a building/admin already exists (the REST equivalent of `isBootstrappingFirstAdmin` becoming permanently false) — the backend enforces the "only once, ever" rule server-side instead of via security rules; `422` invalid input (missing fields, weak password); `400` email already registered.

### Self-service admin sign-up with Google / Apple
- **Method & path:** `POST /auth/sign-up/google`, `POST /auth/sign-up/apple`
- **Request body:**
  ```json
  {
    "idToken": "<provider ID token>",
    "buildingName": "Sunrise Apartments",
    "buildingAddress": "123 Main St, Springfield"
  }
  ```
- **Response body:** same shape as email/password sign-in.
- **Errors:** `409 Conflict` if a building/admin already exists (same rule as the email/password variant); `409 Conflict` (a different reason) if this provider identity already has a `users/{uid}` profile — the REST equivalent of the client-side "already registered" guard in `AuthRepositoryImpl._signUpWithProvider`, since a backend would need to make that same check itself rather than relying on Firestore rules; `401` invalid/expired provider token.

### Sign in with Google / Apple
- **Method & path:** `POST /auth/sign-in/google`, `POST /auth/sign-in/apple`
- **Request body:** `{ "idToken": "<provider ID token>" }`
- **Response body:** same shape as email/password sign-in.
- **Errors:** `401` invalid/expired provider token.

### Fetch current user profile + role
- **Method & path:** `GET /auth/me` (bearer token in header, via `DioClient`'s auth interceptor)
- **Response body:** `{ "profile": {...}, "account": {...} }` (same nested shapes as above)
- **Errors:** `401` expired/invalid session → `DioClient` already has 401-retry/refresh scaffolding in place for this.

### Send password reset email
- **Method & path:** `POST /auth/password-reset`
- **Request body:** `{ "email": "admin@example.com" }`
- **Response body:** `204 No Content`
- **Errors:** `404` no account for that email (or `204` regardless, to avoid account enumeration — a backend-team decision, not a client one).

### Register FCM token
- **Method & path:** `PATCH /auth/me/fcm-token`
- **Request body:** `{ "fcmToken": "..." }`
- **Response body:** `204 No Content`
- **Errors:** none surfaced — this call is already best-effort/non-fatal client-side.

### Sign out
- **Method & path:** `POST /auth/sign-out`
- **Request body:** none (bearer token identifies the session)
- **Response body:** `204 No Content`

### Auth state changes (`watchAuthState`)
No REST equivalent — this is a client-side stream today because Firebase
Auth pushes session changes locally (sign-in/sign-out/token refresh), not
because Firestore is involved. A REST-backed client would instead
re-derive this stream from `SessionManager`'s locally-stored
token/expiry state (already scaffolded for exactly this) rather than
polling a server.

## Architecture notes (for the other 11 features to mirror)

- `domain/repository/auth_repository.dart` — abstract, returns `Result<AuthSessionEntity>` / `Stream<AuthSessionEntity?>`. Zero Firebase types leak past this boundary.
- `data/source/auth_remote_source.dart` — `AuthRemoteSource` abstract class + `AuthFirestoreSource implements AuthRemoteSource` (`@LazySingleton(as: AuthRemoteSource)`). **This is the only file that would need a sibling `AuthApiSource` when a custom backend arrives** — nothing else in this feature changes.
- `domain/entity/auth_entity.dart` (`AuthSessionEntity`) is feature-local, not a `core/models` entity — it's a composed session view, not a 1:1 Firestore document mirror. Compare with Buildings/Apartments, which use `core/models` entities directly since those *are* 1:1 document mirrors.
- `core/firebase/current_session.dart` (`CurrentSession`) is populated here and read by every other feature for `buildingId` scoping.
- `core/firebase/firestore_collections.dart`'s `FirestorePaths.singleBuildingId` (`"main"`) — a **fixed, well-known** building document ID, deliberately not auto-generated. This is what lets `firestore.rules` cheaply check "has anyone already claimed this" via `exists()`; Firestore rules can't express a collection-emptiness query, so a fixed ID is the standard way to make a "singleton" document safely creatable exactly once. Every other feature that already reads `buildingId` off `CurrentSession`/the signed-in user's own doc is unaffected — they never hardcode this constant themselves.
- `data/source/auth_remote_source.dart`'s `AuthProviderIdentity` typedef (`({String uid, String? email, String? displayName})`) — a record type, not a `core/models` entity, since it's a transient shuttle for "what a provider sign-in just told us," never persisted or read back; `bootstrapAdminAccount` consumes its fields directly into `UserModel`/`UserPrivateAccountModel`.

## Notes

- `AppRoutes.initialRoute` now points at `AppRoutes.splash` (was `AppRoutes.auth`) — `SplashScreen` is responsible for routing onward to `dashboard`/`auth` once `AuthBloc` resolves; every other route is unaffected.
- `AuthBloc`'s constructor grew from 7 to 9 params (`SignUpAsAdminWithGoogleUseCase`/`SignUpAsAdminWithAppleUseCase` added) — `flutter pub run build_runner build --delete-conflicting-outputs` was re-run to regenerate `injection.config.dart`.
- No rule changes needed for Google/Apple sign-up: `firestore.rules`'s bootstrap functions only inspect the *resulting* documents (`role == "admin"`, `buildingId == "main"`), not which auth method produced them, so the existing rules (see the Deployment status note below — still not deployed) cover this path too without modification.
- Depends on `users/{uid}/private/account.role` already existing per `05_FIRESTORE_DATABASE.md`.
- **Web setup required for Google Sign-In:** `google_sign_in_web` throws `"ClientID not set"` at runtime on Flutter Web until a Google OAuth Web Client ID is added to `web/index.html` as `<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID">` (or passed to `GoogleSignIn(clientId: ...)` in `FirebaseAuthService`). This is a real per-project credential from the Firebase/Google Cloud console — not something that can be filled in without the project owner's actual OAuth client ID. Android/iOS don't need this (they read it from `google-services.json`/`GoogleService-Info.plist`). Confirmed via a live `flutter run -d web-server` session — the rest of the sign-in UI renders and functions correctly regardless; only the Google button's actual OAuth handshake needs this.
- **Found and fixed a pre-existing, unrelated startup crash** while verifying this UI: `lib/app/app.dart` called `getIt<AppSettingsCubit>()` directly, but `AppSettingsCubit` was never registered in GetIt (no `@injectable` annotation) — crashed on every app start, in web, and presumably mobile/desktop too, predating this feature's work. Also, `bloc_providers.dart` separately constructed its own `AppSettingsCubit` instance for `MultiBlocProvider`, so even if GetIt had a registration, `app.dart` would've been reading a second, out-of-sync instance. Fixed by removing the explicit `bloc:` argument from `app.dart`'s `BlocBuilder<AppSettingsCubit, ...>`, so it resolves the instance already provided by the ambient `MultiBlocProvider` instead of a second one via GetIt.

### Decision record: self-service admin sign-up (2026-07-21)

**Problem:** the product ships without a super-admin able to bootstrap the
first admin via the Firebase Console for every deployment — the user
running this app has no such role, so the manual-bootstrap design didn't
fit how it's actually being handed off/used.

**Options considered:**
1. **Bootstrap-once, single building (chosen).** One building total; sign-up
   as admin is only possible while no admin exists yet; after that, closed
   permanently — further admin changes only via Transfer Admin Role. Low
   risk, small rule change, matches the existing single-building design
   throughout the rest of this doc set.
2. **Multi-tenant, one building per sign-up (rejected for now).** Every
   sign-up creates its own new building — turns this into a real
   multi-customer product on one shared Firebase project. Bigger scope
   (sign-up form needs building fields either way, but the security rules
   would need to let a user create an *arbitrary new* building rather than
   one fixed doc, which is a materially bigger rule-surface change), and
   not what an MVP needs. Worth revisiting explicitly if/when this becomes
   an actual multi-building SaaS product rather than one deployment per
   customer.

**A related question that came up:** can the same Firebase Auth account be
used in both the Admin App and the future Resident App — e.g. after an
admin transfers their role away and becomes a resident again? **Yes** —
there's no technical wall between the two apps; both just authenticate
against the same Firebase project. The Admin App's role-gate only blocks
entry when `role != "admin"`; the Resident App wouldn't gate on role at
all, just on being a building member. One consequence: a self-signed-up
admin who later demotes to `"resident"` has `apartmentId: null` (bootstrap
sign-up never assigns a unit), so they could sign into the Resident App as
a building member but wouldn't be a "Primary Resident" of any apartment
until they separately submit a normal apartment request — consistent with
the existing design, where Transfer Admin Role already requires the
*successor* to already be an occupied resident precisely because an
outgoing admin isn't assumed to hold a unit.

### Deployment status

`firestore.rules` has the new bootstrap rules locally and they compiled
successfully via `firebase deploy --only firestore:rules --dry-run
--project neighbor-hub-33460` — **but they have not been deployed to the
live project.** Sign-up will fail against the real backend until
`firebase deploy --only firestore:rules` is run. This is a deliberate
pause: deploying security rule changes to a live Firebase project is a
shared-infrastructure action the project owner should consciously trigger,
not something done silently as part of a UI build.
