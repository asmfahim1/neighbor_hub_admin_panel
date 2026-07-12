# admen_web_app_ui_functionality.md

# NeighborHub — Admin Panel (Web + App) UI & Functionality Design

**Version:** 0.2 (Functionality-first design — UI visuals intentionally deferred)
**Applies to:** `neighbor_hub_admin_panel` (this repo) — Admin Mobile App + Admin Web Portal, one Arcle/BLoC codebase, responsive
**Depends on:** `02_ADMIN_SYSTEM.md`, `04_UI_UX_GUIDELINES.md`, `05_FIRESTORE_DATABASE.md`, `06_FIREBASE_SECURITY.md`, `10_DATA_FLOW_DIAGRAM.md`, `14_APP_ARCHITECTURE.md`, `15_ADMIN_UI_FUNCTIONALITY_PLAN.md`, `firestore.rules`
**Status:** Draft for approval. Functionality is the focus — visual design is being handled separately and will be layered on top of these same screens/flows once ready.

## 0. How This Document Fits With the Existing Docs

This document does not replace `15_ADMIN_UI_FUNCTIONALITY_PLAN.md` — it makes it concrete and current:

* Replaces every mention of **Riverpod** with **BLoC** (`flutter_bloc` + `equatable`, per `arcle.yaml: state: bloc`, already scaffolded in this repo).
* Removes the **Cloud Function / Blaze plan** dependency for push notifications. Phase 1 MVP runs entirely on the **Spark (free) plan** — no billing, no Cloud Functions. Killed-app push notifications are explicitly **out of scope** for this phase (agreed decision).
* Assumes **Admin App and Resident App are separate Flutter projects/repos** (no shared pub package, no monorepo) — so this document calls out exactly which modules should be built so they can be **copy-pasted** into the future Resident App repo with minimal changes (§3).
* Assumes **single Admin per building** for now, with a documented handoff/leave flow (§7.5.4) instead of a multi-admin console.
* Adds one schema field not in `05_FIRESTORE_DATABASE.md` yet — `buildings/{buildingId}.adminUid` — needed to solve a real gap: a resident's client has no way to look up who the admin is (role lives in an unreadable private subdocument) in order to start a chat with them. See §7.10.1.
* Every screen below lists the **exact Firestore fields/collections** it reads and writes, so functionality can be implemented and tested without re-deriving the schema from scratch.

## 1. Product Surfaces

One Arcle/BLoC codebase, two responsive layouts of the same feature set — not two different apps:

* **Admin App** — phone/tablet, adaptive nav (bottom nav on phone, rail on tablet/landscape). Optimized for fast operational actions: approvals, moderation, announcements, chat.
* **Admin Web Portal** — desktop, persistent left sidebar. Optimized for heavier data entry: building setup, bulk apartment generation, analytics review.

Same BLoC, same repositories, same Firestore rules, same data — only the presentation layer's layout/density differs, per `04_UI_UX_GUIDELINES.md` §11 and `15_ADMIN_UI_FUNCTIONALITY_PLAN.md` §5.3.

## 2. Global Architecture Decisions (Locked For This Phase)

| Decision | Choice | Why |
|---|---|---|
| State management | **BLoC** (`flutter_bloc`, `equatable`) | Already scaffolded (`arcle.yaml`); supersedes `14_APP_ARCHITECTURE.md`'s Riverpod default |
| DI | `get_it` + `injectable` (already scaffolded) | Standard Arcle pattern |
| Firebase plan | **Spark (free)**, no Cloud Functions | Explicit "no billing in Phase 1 MVP" requirement |
| Push notifications (killed app) | **Not built in Phase 1.** In-app + local notifications only, while the app process is alive (foreground or backgrounded-but-alive) | Depends on a Cloud Function + Blaze, which is out of scope |
| Building scope | **Single building** — one project-wide `buildingId`, auto-filled on every document | Per `05_FIRESTORE_DATABASE.md` §2 and your explicit "one building for now" instruction |
| Admin model | **Single admin per building**, with an in-app handoff flow before self-removal | Simpler than a promotion console; safe because self-elevation is blocked at the rules layer and self-demotion is the only role transition a user can do to themselves |
| Repos | Admin App and Resident App are **separate Flutter projects** | No Melos/shared pub package — reuse is achieved by copy-pasting self-contained modules (§3), not a shared dependency |

## 3. Shared/Reusable Modules (Build Once, Copy Into Resident App Later)

Structure these as dependency-light modules inside `lib/core/` so each can be lifted into the Resident App repo with near-zero rework when that project starts. "Reusable as-is" means it has no admin-specific business logic baked in.

| Module | Location (this repo) | Reusable as-is? | Notes |
|---|---|---|---|
| Theme tokens (light/dark `ColorScheme`, `TextTheme`, category chip colors, status colors) | `lib/core/theme_handler/` | ✔ Yes | Directly implements `04_UI_UX_GUIDELINES.md` §4–§6 token contract. Copy the whole folder. |
| Firestore/Auth wrapper services (typed repository base class, building-scoped query helpers, batch-write helpers) | `lib/core/firebase/` (new) | ✔ Yes | E.g. `createPostBatch()` (post + post_authorship dual write), `approveResidentBatch()`, generic `buildingScopedQuery()`. Business-agnostic plumbing. |
| Firestore data models (`Post`, `User`, `Apartment`, `ApartmentRequest`, `Announcement`, `Poll`, `Notification`, `Conversation`, `Message`) | `lib/core/models/` (new) | ✔ Yes | Mirrors `05_FIRESTORE_DATABASE.md` field-for-field. Single source of truth so admin/resident never drift on field names. |
| Constants (collection names, status enums, category enums, notification categories) | `lib/core/constants/` (new) | ✔ Yes | Prevents typo'd string literals like `"occupied"` from diverging between apps. |
| Local notification service (`flutter_local_notifications` wrapper + Firestore `notifications` listener → local push while app alive) | `lib/core/notifications/` (already scaffolded) | ✔ Mostly | Core listener/show-notification logic is shared; only which categories map to which admin/resident screens differs. |
| `firebase_options.dart` / Firebase app registration | `lib/firebase_options.dart` | ✘ No | Each app registers its own Firebase "app" (even inside the same Firebase project) — must run `flutterfire configure` separately per repo, per `14_APP_ARCHITECTURE.md` §8. |
| Feature business logic (dashboard, moderation, apartments, feed, chat UI, etc.) | `lib/features/*` | ✘ No | Genuinely different between the two products — not meant to be shared. |

**Action for later:** when the Resident App repo is created, copy `theme_handler/`, the new `firebase/`, `models/`, `constants/`, and `notifications/` folders over first, before writing any resident feature.

## 4. Navigation & Layout

### 4.1 Admin App (phone/tablet)

Bottom nav (phone) / rail (tablet+landscape): `Dashboard` · `Residents` · `Moderation` · `Announcements` · `More`
`More` sheet contains: `Apartments`, `Polls`, `Analytics`, `Building Settings`, `Chat`, `Notifications`, `Profile`.

### 4.2 Admin Web Portal (desktop)

Persistent left sidebar: `Dashboard` · `Building` · `Apartments` · `Residents` · `Moderation` · `Announcements` · `Polls` · `Analytics` · `Chat` · `Notifications` · `Profile`
Top bar: search/filter context, quick actions, notification bell.

### 4.3 Responsive Rule

Same information architecture at every breakpoint — only density/interaction changes (tables ↔ cards, sidebar ↔ bottom nav), per `04_UI_UX_GUIDELINES.md` §11. No screen exists on web that doesn't also exist on mobile, or vice versa.

## 5. Cross-Cutting Functionality Rules

These apply to every feature below, not repeated per-section:

* **Realtime by default.** Every list/detail screen is backed by a Firestore `Stream` → BLoC state, not a one-shot fetch. No manual "refresh" button should ever be required for data that's already covered by a listener.
* **Confirmation on destructive actions.** Delete post/comment/announcement, remove resident, block apartment, self-demote-and-leave — all require an explicit confirm dialog/sheet whose copy explains the consequence (not just repeats the button label).
* **Rule failures map to human copy.** E.g. a blocked duplicate-request write shows "This resident already has an active apartment," not a raw Firestore permission-denied string.
* **Offline-aware.** Reads serve from Firestore's local cache first; writes queue offline and flush on reconnect (Firestore SDK default behavior) — the admin app should never show a blank screen purely from a dropped connection.
* **Atomicity via `WriteBatch`, never Cloud Functions.** Every multi-document operation (approve resident, create post + authorship, react + counter, comment + counter, promote/demote admin) is one client-side `WriteBatch`, matching `06_FIREBASE_SECURITY.md` §8 and the fixed `firestore.rules`.

## 6. Firestore Schema Addendum For This Document

### 6.1 `buildings/{buildingId}.adminUid` (new field)

| Field | Type | Notes |
|---|---|---|
| `adminUid` | string | The uid of the building's current single admin. Set manually alongside the developer's one-time bootstrap (`06_FIREBASE_SECURITY.md` §2.1); updated by the Transfer-Admin-Role flow (§7.5.4) in the same batch that changes `role` on both users' private docs. |

**Why:** solves the "how does a resident's client discover the admin's uid" problem without giving residents read access to anyone's `role` field. `buildings/{buildingId}` is already readable by every building member and writable only by the admin — no rule change required, purely an additional field.

No rule changes are needed for this addition; the existing `buildings/{buildingId}` read/write rules already cover it.

## 7. Feature-By-Feature Design & Functionality

Each feature lists: **Arcle module**, **screens (app/web)**, **data displayed (exact fields)**, **functionality**, **realtime/notification behavior**, and **empty/error states**.

### 7.1 Authentication & Session — `auth`

**Screens:** Sign In (Email/Password, Google), Session gate (role check).

**Data:** `users/{uid}` (public), `users/{uid}/private/account.role`.

**Functionality:**
* Sign in via Firebase Auth (email/password or Google).
* After sign-in, read `private/account.role`. If `role != "admin"`, block entry with a clear message ("This app is for building administrators") — the Admin App is not a place a resident-role account should land, even though the same Firebase project serves both.
* Session persists via Firebase Auth's own persistence; no custom token handling.

**Notes:** the very first admin account is bootstrapped manually in the Firebase Console per `06_FIREBASE_SECURITY.md` §2.1 — this app has no "become the first admin" self-service path, by design.

### 7.2 Dashboard — `dashboard`

**Screens:** Dashboard (both surfaces; web adds larger chart area, app shows a scroll of cards).

**Data displayed:**
* **Apartment KPIs** — counts from `apartments` grouped by `status` (`vacant`/`pending_approval`/`occupied`/`blocked`), computed client-side from a single realtime query on `apartments where buildingId == X` (small dataset at this scale — one listener, group in memory, no aggregation queries needed).
* **Floor vs. Occupancy breakdown** (your D-1 request) — from the same `apartments` listener, grouped by `floor`: for each floor, total apartments, occupied count, vacant count, pending count, blocked count. Rendered as a table on web, stacked cards on app (e.g. "Floor 1 — 4 apartments, 3 occupied, 1 vacant").
* **Resident count** — count of `apartments where status == "occupied"` (equivalently, `users where buildingId == X && apartmentId != null`).
* **Pending requests queue** — `apartment_requests where buildingId == X && status == "pending"`, with a jump-in action to §7.5.1.
* **Engagement summary ("user interaction")** — total posts, total comments, total reactions (sums of `posts.commentCount`/`reactionCount` across the building's `posts`), most active residents (top N by post+comment+reaction count, computed client-side over the current post set), poll participation rate (`votes` count ÷ resident count, per active poll).
* **Recent activity feed** — latest N documents across `posts`, `announcements`, recently-decided `apartment_requests`, ordered by `createdAt desc`.

**Functionality:** read-only surface; every card/row deep-links into the relevant feature (tap a pending request → Residents §7.5.1; tap a KPI → Apartments §7.4).

**Empty state:** first-run building with zero apartments shows "Set up your building" CTA into §7.3.

### 7.3 Building — `buildings`

**Screens:** Building Profile (app: single form screen; web: form + apartment-generation panel).

**Data:** `buildings/{buildingId}`: `name`, `address`, `totalFloors`, `apartmentsPerFloor`, `createdAt`, `adminUid` (read-only display, changed only via §7.5.4).

**Functionality:**
* Create/update `name`, `address`, `totalFloors`, `apartmentsPerFloor`.
* **Bulk apartment generation (Web only):** given `totalFloors` × `apartmentsPerFloor`, generate that many `apartments` documents in batched writes (Firestore batches cap at 500 writes — chunk accordingly), each defaulting to `status: "vacant"`, `primaryResidentUid: null`, numbered predictably (e.g. floor-major numbering, editable after generation).
* Prevent re-generating apartments that already exist for a floor/number combination (dedupe check before writing).

**Validation:** `totalFloors`/`apartmentsPerFloor` must be positive integers; changing them after apartments already exist should warn the admin rather than silently mismatch the dashboard's floor breakdown.

### 7.4 Apartments — `apartments`

**Screens:** Apartments List (web: searchable/filterable table with inline status edit; app: grouped-by-floor cards), Apartment Detail (create/edit sheet or page).

**Data:** `apartments/{apartmentId}`: `buildingId`, `number`, `floor`, `description`, `status`, `primaryResidentUid`, `updatedAt`. When `status == "occupied"`, resolve `primaryResidentUid` → `users/{uid}.displayName` for display.

**Functionality:**
* Create/update/delete an apartment.
* Change `status`. UI must reflect the rules-enforced invariant: setting `occupied` requires an existing approved resident binding (this is not a free toggle — it only happens via the approval batch in §7.5.1); the UI should disable manually picking "Occupied" directly and instead route through approval. Admin *can* freely toggle between `vacant` and `blocked` (maintenance) manually.
* Search/filter by floor, status, number.

**Empty state:** "No apartments yet" → CTA into bulk generation (§7.3).

### 7.5 Residents — `residents`

Four sub-flows under one module.

#### 7.5.1 Pending Request Queue (Approval Workflow)

**Data:** `apartment_requests where buildingId == X && status == "pending"`: `apartmentId`, `familyNote`, `createdAt`, plus the requester's `users/{uid}.displayName`.

**Functionality — Approve:**
One `WriteBatch`, three writes (matches `06_FIREBASE_SECURITY.md` §5.4 and the fixed rules):
1. `apartment_requests/{uid}.status → "approved"`, `decidedBy → adminUid`, `decidedAt → now`.
2. `apartments/{apartmentId}.status → "occupied"`, `primaryResidentUid → uid`.
3. `users/{uid}.buildingId → X`, `apartmentId → apartmentId` (only valid the *first* time, per the new `isAdminApprovalUpdate` rule).

**Functionality — Reject:** `apartment_requests/{uid}.status → "rejected"`, `decidedBy`, `decidedAt` set; apartment stays `vacant` (never touched, since it was never assigned).

**Notification:** create a `notifications` doc for the requester (`category: "announcement"`-style approval/rejection message, per `03_RESIDENT_SYSTEM.md` §5).

**Admin-side alert (no Cloud Function needed):** the Admin App keeps a live listener on `apartment_requests where status == "pending"`. On `docChanges()` reporting a newly-`added` document while the app is running, show a local notification via `flutter_local_notifications` (foreground/background-alive only — matches the agreed no-push-when-killed limitation).

#### 7.5.2 Resident Directory

**Data:** `users where buildingId == X` — `displayName`, `apartmentId` (resolved to apartment number), `photoUrl`. Includes the admin's own public profile so residents (in the future Resident App) can find "Building Management" for chat — resolved via `buildings/{buildingId}.adminUid` rather than a directory filter hack.

**Functionality:** list + search; tap a resident → Resident Detail.

#### 7.5.3 Resident Detail & Removal

**Data:** profile fields, bound `apartmentId`, join date (`apartment_requests.decidedAt` or `users.createdAt`), lightweight activity summary (post/comment/reaction counts for that `authorUid`).

**Functionality — Remove resident:** one `WriteBatch`:
1. `users/{uid}.apartmentId → null` (via the new `isAdminRemovalUpdate` rule; `buildingId` stays as-is).
2. `apartments/{apartmentId}.status → "vacant"`, `primaryResidentUid → null`.
3. `users/{uid}/private/account.accountStatus → "removed"` (via `isAdminPrivateUpdate`).

Surfaces a confirmation dialog explaining the consequence (resident loses feed/chat access; their post/comment history remains for audit, per `02_ADMIN_SYSTEM.md` §5.3).

**Also handles:** processing a resident's self-submitted "Request Account Deletion" (`accountStatus == "deletion_requested"`) — same removal action, triggered from a filtered queue view instead of an ad-hoc admin decision.

#### 7.5.4 Transfer Admin Role & Leave (your D-3 answer)

**Screens:** Profile → "Transfer Admin Role" (§7.12), which opens a resident picker scoped to this module.

**Functionality:** admin picks a resident (must currently be an occupied resident, i.e. `apartmentId != null`) as successor. One `WriteBatch`:
1. `users/{successorUid}/private/account.role → "admin"` (via `isAdminPrivateUpdate` — current admin acting on a *different* uid).
2. `users/{currentAdminUid}/private/account.role → "resident"` (via the new self-demotion carve-out in `isSelfPrivateUpdate`).
3. `buildings/{buildingId}.adminUid → successorUid`.

After this batch, the outgoing admin is a normal resident and, if they want to fully leave, uses the standard self-service "Request Account Deletion" — which the *new* admin then processes via §7.5.3.

**Guardrail:** the picker only allows selecting an existing occupied resident — if there are zero other residents, the UI explains that a successor is required and that leaving with none requires the documented manual Firebase Console fallback (`06_FIREBASE_SECURITY.md` §2.1 pattern reused) — not something this app builds a self-service path for.

### 7.6 Moderation — `moderation`

**Screens:** Feed Moderation list (all posts in the building, admin view), Post Detail (with real-author reveal), Comment thread (with delete).

**Data:** `posts` (all fields including `isPinned`/`isLocked`); real author resolved via `post_authorship/{postId}.authorUid` regardless of `isAnonymous`; `posts/{postId}/comments`.

**Functionality:**
* Delete any post / any comment.
* Lock comments (`isLocked → true`) — blocks new comments, existing stay visible.
* Pin a post (`isPinned → true`) — moves to top of resident feed.
* Real-author reveal is admin-only (never shown to residents), sourced from `post_authorship`, per `05_FIRESTORE_DATABASE.md` §4.
* All actions logged implicitly by `updatedAt`/who performed it — no separate audit collection exists yet in the schema; if you want a formal audit trail, that's a schema addition to flag, not something silently added here.

**Note:** there is no resident-facing "report" queue in MVP (future enhancement per `02_ADMIN_SYSTEM.md` §12) — admin browses the full feed to moderate.

### 7.7 Announcements — `announcements`

**Screens:** Announcement list, Composer (create/edit).

**Data:** `announcements/{id}`: `title`, `body`, `createdBy`, `createdAt`.

**Functionality:** create/edit/delete. On create, also write a `notifications` doc per resident in the building with `category: "announcement"` (batched — chunk if the resident count ever exceeds a single batch's 500-write limit, not a concern at ~100 residents). Always attributed to "Building Management," never anonymous.

### 7.8 Polls — `polls`

**Screens:** Poll list (active/closed chips), Poll Creator, Results view.

**Data:** `polls/{id}`: `question`, `options[{id, text, voteCount}]`, `status`, `closesAt`; `polls/{id}/votes` for participation counting.

**Functionality:** create single-choice poll; close manually or let `closesAt` pass (client checks expiry when rendering — no server-side cron since there's no Cloud Function); view live/final results; participation rate feeds the Dashboard/Analytics.

### 7.9 Analytics — `analytics`

**Screens:** deeper, chart-based version of the Dashboard's summary data (web: full charts + export-ready tables; app: summary + drill-down).

**Data:** same sources as §7.2, over a longer window — occupancy trend, post/comment/reaction volume over time, category breakdown (`discussion`/`recommendation`/`help`/`service`/anonymous), most-active-residents leaderboard, poll participation history.

**Functionality:** read-only. All computed client-side from existing collections (no `analytics` collection in the schema, by design per `05_FIRESTORE_DATABASE.md`) — acceptable at single-building/~100-resident scale; flagged in §11 if this ever needs revisiting at larger scale.

### 7.10 Chat — `chat`

**Screens:** Chat List, Conversation.

**Data:** `conversations where participantUids array-contains myUid`; `conversations/{id}/messages`.

**Functionality:** admin has their own 1:1 conversations with residents — same rules as a resident participant (`06_FIREBASE_SECURITY.md` §6: admin has no special chat-oversight power over conversations they're not part of). Admin starts a chat from the Resident Directory (§7.5.2), same "tap a contact" pattern as the future Resident App.

#### 7.10.1 The Discovery Gap (Resolved)

The open loose end from the previous discussion: a resident's client cannot read another user's `role` field, so it has no way to find "who is the admin" to start a chat. Resolved via `buildings/{buildingId}.adminUid` (§6.1) — any building member can read the building doc and resolve the admin's public profile from that uid. This admin app doesn't need to do anything extra to support it (it's a resident-app-side lookup) beyond keeping `adminUid` correct, which the Transfer flow (§7.5.4) already guarantees.

### 7.11 Notifications — `notifications`

**Screens:** Notification inbox (in-app), local system notification while app is alive.

**Data:** `notifications where recipientUid == myUid`, ordered `createdAt desc`, filterable by `category`.

**Functionality:**
* Live Firestore listener drives both the in-app inbox and a local notification (via `flutter_local_notifications`) when a new doc arrives while the app process is alive.
* Categories relevant to admin: `chat` (new message), plus the direct `apartment_requests` listener described in §7.5.1 (not a `notifications` doc, since there's no way for the requester to target `recipientUid` at the admin without the same discovery problem §7.10.1 solves for chat — chat notifications work because the conversation doc already carries the admin's uid by the time a message notification is created).
* **Explicitly out of scope for Phase 1:** delivery when the app is fully killed. This is a known, agreed limitation, not a bug.

### 7.12 Profile & Settings — `profile`

**Screens:** Profile form, Theme toggle, Sign out, "Transfer Admin Role" entry point (§7.5.4).

**Functionality:** update own `displayName`/`photoUrl` (self-update path, unaffected by any of the fixes in §6); switch light/dark/system theme preference (local preference, `04_UI_UX_GUIDELINES.md` §4.3); sign out; entry point into the admin handoff flow.

## 8. Firestore Read/Write Quick Reference

| Screen | Reads | Writes |
|---|---|---|
| Dashboard | `apartments`, `apartment_requests`, `posts`, `announcements` | — |
| Building | `buildings` | `buildings`, bulk `apartments` (generation) |
| Apartments | `apartments` | `apartments` |
| Residents — Requests | `apartment_requests`, `users` | `apartment_requests`, `apartments`, `users`, `notifications` |
| Residents — Directory/Detail | `users`, `posts` (activity summary) | `users`, `apartments`, `users/private/account` |
| Residents — Transfer Admin | `users` | `users/private/account` (both parties), `buildings` |
| Moderation | `posts`, `post_authorship`, `posts/comments` | `posts`, `posts/comments` |
| Announcements | `announcements` | `announcements`, `notifications` (batched, per resident) |
| Polls | `polls`, `polls/votes` | `polls` |
| Analytics | `apartments`, `posts`, `polls` | — |
| Chat | `conversations`, `conversations/messages` | `conversations`, `conversations/messages`, `notifications` |
| Notifications | `notifications` | `notifications` (mark read) |
| Profile | `users`, `users/private/account` | `users`, `users/private/account` |

## 9. Arcle Feature Module Plan

```text
apps/admin_app/
  lib/
    core/
      theme_handler/        # shared, copyable
      firebase/              # shared, copyable (repository base, batch helpers)
      models/                 # shared, copyable
      constants/              # shared, copyable
      notifications/          # shared, mostly copyable
    features/
      auth/
      dashboard/
      buildings/
      apartments/
      residents/
      moderation/
      announcements/
      polls/
      analytics/
      chat/
      notifications/
      profile/
```

Each feature follows Arcle's generated `data/domain/presentation` split (BLoC in `presentation`), matching `14_APP_ARCHITECTURE.md` §7's module list, updated with `chat` promoted to its own admin-side module (previously only implied) and `auth` made explicit.

## 10. Delivery Order

1. Shared modules (§3): theme, models, constants, Firebase wrapper, notification service.
2. `auth` — sign-in + role gate.
3. `dashboard` + `residents` (approval queue is core admin value, per `15_ADMIN_UI_FUNCTIONALITY_PLAN.md` §10).
4. `buildings` + `apartments`.
5. `moderation` + `announcements`.
6. `polls` + `analytics`.
7. `chat` + `notifications`.
8. `profile` (incl. Transfer Admin Role).
9. Responsive polish pass for the Web Portal once all functionality is verified end-to-end.

## 11. Open Items For Your Review

1. **`adminUid` on `buildings`** (§6.1) — confirm you're fine adding this field; if so I'll also patch `05_FIRESTORE_DATABASE.md` to document it.
2. **No formal moderation audit log** — `02_ADMIN_SYSTEM.md` §5.4 says actions "are logged... for internal audit" but the schema has no audit collection. Do you want a lightweight `moderation_log` collection now, or is implicit (relying on `updatedAt` + your own memory of actions) acceptable for Phase 1?
3. **Analytics at scale** — client-side aggregation over all `posts`/`apartments` is fine at ~100 residents/one building; flagging now so it's a conscious choice, not a surprise later if resident count grows materially.
4. Confirm the **feature/module list and delivery order** in §9–§10 before I start scaffolding via `arcle feature <name>`.

Once you approve (or amend) the above, I'll proceed to scaffold the feature modules per §9 and start implementing in the delivery order in §10.
