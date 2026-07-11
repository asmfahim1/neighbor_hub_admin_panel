# 14_APP_ARCHITECTURE.md

# NeighborHub — Flutter App Architecture

**Version:** 0.1 (Planning Phase)
**Depends on:** `05_FIRESTORE_DATABASE.md`, `06_FIREBASE_SECURITY.md`, `04_UI_UX_GUIDELINES.md`
**Addendum note:** This document sits outside the original 13-doc numbering plan — it covers Flutter/tooling-level technical architecture that the original structure didn't reserve a slot for. Numbered `14` to avoid colliding with reserved `07`–`13` topics.

## 1. Purpose

Define the concrete Flutter project structure, toolchain, state management, and cost architecture so implementation can start without any further architectural decisions. Any developer or coding agent should be able to read this document and know exactly where a new feature's code goes, how it talks to Firebase, and why the project is shaped the way it is.

## 2. Scope

Covers: toolchain (Arcle CLI), the two-app-plus-shared-package project layout, Clean Architecture layering per app, Firebase project/app registration, environment strategy, and the zero-cost notification implementation pattern. Does **not** cover visual design (`04_UI_UX_GUIDELINES.md`) or data modeling (`05_FIRESTORE_DATABASE.md`) — those are referenced, not repeated.

## 3. Assumed Defaults (flag before building)

Two decisions were defaulted to keep planning moving, and should be treated as **easily reversible until the first feature is scaffolded**, not as locked-in fact:

| Decision | Default chosen | Why | How to change |
|---|---|---|---|
| State management | **Riverpod** | Type-safe, and Firestore's `Stream`-based realtime listeners (feed, chat, notifications) map cleanly onto Riverpod's `StreamProvider` with minimal boilerplate | Re-run `arcle create` with the BLoC or GetX flag before any feature code exists; no cost to switching now, high cost after |
| Firebase environment count | **Single Firebase project** (no separate dev/staging/prod projects) | At 2 buildings / ~100 residents, the operational overhead of multiple projects isn't justified yet, and it keeps setup to one `flutterfire configure` run | Add a second project and re-run `flutterfire configure` with a `--project` flag per app when the team/scale grows |

## 4. Toolchain

**Arcle CLI** (`https://pub.dev/packages/arcle`) is used to scaffold both apps with Clean Architecture out of the box: a `core/` layer (DI, env config, localization, API client scaffolding) plus per-feature `data/domain/presentation` folders, generated via `arcle feature <name>`.

Relevant commands used throughout the project:

| Command | When used |
|---|---|
| `arcle create <name>` | Once per app, at project bootstrap |
| `arcle feature <name>` | Once per feature module (see §7 for the feature list) |
| `arcle review` | Pre-commit quality gate (lint + test) |
| `arcle doctor` | Sanity-check project health after setup or dependency changes |
| `arcle verify` | Structural verification that generated layers weren't broken by manual edits |
| `arcle build apk` | Local debug/release builds for the two mobile apps |

Arcle's built-in API client (Dio-based) is designed for REST backends. NeighborHub has no REST backend — all data access is through the Firebase SDKs (`cloud_firestore`, `firebase_auth`, `firebase_messaging` for future push). The Dio/API-client layer Arcle generates is simply **not used**; Firebase SDK calls are wrapped instead inside the `data/` layer's repository implementations, following the same Clean Architecture seams Arcle already scaffolds (domain repository interface → data repository implementation, just backed by Firestore instead of Dio).

## 5. Project Layout — Two Apps, One Shared Package

Per the product decision in `03_RESIDENT_SYSTEM.md` / `02_ADMIN_SYSTEM.md`: **Resident App** and **Admin (App + Web Portal)** are the two products, and the Resident App is also scoped for web from the start (mobile-first UI now, responsive web later) so it isn't re-architected when a resident web portal is added.

```
neighborhub/
├── packages/
│   └── neighborhub_core/          # plain Dart/Flutter package, NOT arcle-generated
│       ├── models/                # Post, User, Apartment, Comment, Notification,
│       │                          # Conversation, Poll — mirrors 05_FIRESTORE_DATABASE.md exactly
│       ├── constants/             # collection names, category enums, notification
│       │                          # categories, apartment statuses — single source of
│       │                          # truth so both apps can't drift out of sync
│       ├── firebase/              # thin wrappers over cloud_firestore/firebase_auth
│       │                          # calls (e.g. createPostBatch(), which performs the
│       │                          # posts + post_authorship dual-write from 05 §4)
│       └── theme/                 # light/dark ColorScheme + TextTheme from
│                                  # 04_UI_UX_GUIDELINES.md, consumed by both apps
│
├── apps/
│   ├── resident_app/               # arcle create (Riverpod), Android + iOS + Web targets
│   │   └── (Clean Architecture: core/, features/{feed,chat,notifications,
│   │        resident_directory,profile,announcements,polls}/{data,domain,presentation})
│   │
│   └── admin_app/                  # arcle create (Riverpod), Android + iOS + Web targets
│       └── (Clean Architecture: core/, features/{dashboard,apartments,residents,
│            moderation,announcements,polls,analytics}/{data,domain,presentation})
│
└── (no Melos) — apps depend on neighborhub_core via a plain relative
   path dependency in pubspec.yaml: `path: ../../packages/neighborhub_core`
```

**Why a shared package instead of duplicating models/services in both apps:** `posts`, `users`, `notifications`, etc. are read and written by *both* apps against the *same* Firestore collections. If the `Post` model or the dual-write logic for anonymous posts (`05_FIRESTORE_DATABASE.md` §4) were hand-duplicated in each app, the two copies would eventually drift and one app would silently write a document the other can't parse. A single shared package makes that structurally impossible.

**Why not a full Melos monorepo:** two apps and one internal package don't need Melos's multi-package versioning/bootstrapping machinery — a plain `path:` dependency achieves the same code-sharing with far less tooling overhead. Revisit Melos only if a third Flutter app appears (see §9).

## 6. Notification Architecture — Foreground, Background, and Killed

The "no costing" requirement is satisfied on **near-zero actual cost**, not on avoiding Blaze entirely: real background/killed-app push requires a trusted server call to FCM (a device token alone can't be used to send a push without the project's service-account credentials), and the only trusted server available here — with no custom backend — is a single Cloud Function. That Function requires the **Blaze plan**. At MVP scale (~100–200 residents), its usage sits at a small fraction of Cloud Functions' free tier (2M invocations / 400,000 GB-seconds per month), so the realistic monthly bill is **$0.00** — the two required safety nets (§6.4) exist to keep it that way even under a bug or abuse spike, not because a bill is expected.

### 6.1 Data path (all three app states)

1. Resident B reacts to / comments on / messages Resident A, or an admin publishes an announcement.
2. The client writes a `notifications/{id}` document for the recipient(s) directly — per `05_FIRESTORE_DATABASE.md` §3.13 and `06_FIREBASE_SECURITY.md` §5.13, this remains a trusted client write validated by rules, not a Cloud Function call. This part of the design is unchanged and still free regardless of plan.
3. **Foreground:** Resident A's app holds a live Firestore `StreamProvider` on `notifications where recipientUid == myUid`. The in-app notification center and badge update instantly — no FCM involved.
4. **Background (app minimized, process alive):** the same Firestore listener typically still fires; a local notification is shown from within the app. Still no FCM involved in most cases.
5. **Killed / fully closed:** this is the one path that needs the Cloud Function.

### 6.2 The push-sending Cloud Function

* **Trigger:** Firestore `onCreate` on `notifications/{id}`.
* **Steps:**
  1. Read the new notification document (`recipientUid`, `category`, `title`, `body`, `relatedPostId`/`relatedConversationId`).
  2. Read `users/{recipientUid}/private/account.fcmToken` — the Admin SDK bypasses Firestore security rules entirely, so the fact this field lives in a resident-private subdocument (`06_FIREBASE_SECURITY.md` §5.2b) doesn't complicate the Function at all.
  3. If `fcmToken` is null, skip (the resident has never logged in on a device with messaging permission granted, or was already cleared per step 4).
  4. Call `admin.messaging().send({ token, notification: { title, body }, data: { category, relatedPostId, relatedConversationId } })`.
  5. On failure with `messaging/registration-token-not-registered` (or `invalid-argument`), clear `fcmToken` on that user's private doc — self-healing, so a stale token from an uninstalled app doesn't generate a failed send (and a support ticket) on every future notification.
* **This is the only Cloud Function in the project.** No other write path in `06_FIREBASE_SECURITY.md` needs server-side logic.

### 6.3 Client-side token lifecycle (in `neighborhub_core`)

* On successful login and on every app cold start, request the current FCM token and write it to `users/{uid}/private/account.fcmToken` if it differs from what's stored.
* Register a listener on Firebase Messaging's token-refresh stream and repeat the same write whenever it fires — tokens rotate periodically and after reinstalls; a one-time write at account creation (as originally proposed) would silently go stale for a growing fraction of users over time.
* This lifecycle logic belongs in `neighborhub_core` (not duplicated per app) since both `resident_app` and `admin_app` need it identically.

### 6.4 Cost safety nets (set once, at Firebase project setup)

* **Cloud Functions `maxInstances`** capped at a small number (e.g. 10) — bounds worst-case concurrent execution cost regardless of trigger volume.
* **Firebase Budget Alert** on the project, e.g. an email at $1 of spend — since the expected bill is $0, any alert firing is itself a signal something is misbehaving, not a normal event.
* Both are one-time console settings, not code — no ongoing engineering cost.

### 6.5 Why this doesn't change the rest of the architecture

The five notification categories (`announcement`, `chat`, `reaction`, `comment`, `poll`), their client-side filtering UI, and every other collection's security rules are completely unaffected by adding this one Function — it only *reads* `notifications` after the client has already written it. This is exactly the "pure additive upgrade" that was flagged as the deferred path in earlier planning; it's being adopted now instead of deferred, per the product decision to support real background/killed-app notifications from the start.

## 7. Feature Modules (via `arcle feature <name>`)

| Resident App | Admin App |
|---|---|
| `feed` (incl. create post, anonymous logic) | `dashboard` (analytics cards) |
| `post_detail` (comments, reactions, bookmarks) | `apartments` (CRUD + status lifecycle) |
| `announcements` | `residents` (approval queue, directory) |
| `notifications` | `moderation` (delete/lock/pin) |
| `chat` (chat list + conversation) | `announcements` (create/edit) |
| `resident_directory` | `polls` (create/close) |
| `polls` | `analytics` |
| `profile` (incl. deletion request) | `profile` |

Each feature follows Arcle's generated `data/domain/presentation` split; `domain` repository interfaces are app-local, but their Firestore-backed implementations in `data` call into `neighborhub_core/firebase` wrappers rather than touching `cloud_firestore` directly — this keeps the dual-write/batch contracts from `06_FIREBASE_SECURITY.md` §8 in exactly one place instead of scattered across features.

## 8. Firebase Project Setup

* **One Firebase project** for both apps (see §3 for rationale).
* Register **6 Firebase "apps"** under that one project: `resident-android`, `resident-ios`, `resident-web`, `admin-android`, `admin-ios`, `admin-web`. All 6 share the same Firestore database, Auth users, and Hosting site (the two web targets are deployed as separate Hosting sites within the same project — free on Spark).
* Run `flutterfire configure` once inside each of `resident_app` and `admin_app` to generate that app's `firebase_options.dart`, pointing at the appropriate registered Firebase apps.
* Firestore Security Rules (`06_FIREBASE_SECURITY.md`) are written and deployed **once**, project-wide — both apps are bound by the same rules since they share the same backend and the same trust boundary.

## 9. Notes

* No custom backend server exists or is planned for MVP — every *write* path in `06_FIREBASE_SECURITY.md` remains a trusted client write validated by rules. The one Cloud Function (§6.2) is a narrow exception scoped to reading `notifications` and sending/clearing an FCM token; it is not a general-purpose backend and no other feature routes through it. This keeps the project consistent with the "Firebase Only" principle in `00_PROJECT_OVERVIEW.md` even while on the Blaze plan.
* If a third Flutter app is ever added (e.g., a public marketing site, or the resident web portal becomes fully independent rather than the same responsive `resident_app` codebase), revisit adopting Melos at that point — two apps plus one package doesn't justify it yet.

## 10. Future Enhancements

* Move `role` from `users/{uid}/private/account` to Auth Custom Claims now that Cloud Functions exist anyway (`06_FIREBASE_SECURITY.md` §9)
* Multi-device push support — `fcmToken` becomes an array, and the Cloud Function sends to all of a resident's registered devices (`05_FIRESTORE_DATABASE.md` §3.2b)
* Split into multiple Firebase projects (dev/staging/prod) once team size or release cadence justifies the overhead
* Melos adoption if a third app is added
