# 06_FIREBASE_SECURITY.md

# NeighborHub — Firebase Security Rules & Permissions

**Version:** 0.1 (Planning Phase)
**Depends on:** `05_FIRESTORE_DATABASE.md` (read that first — this document assumes its schema and doc-ID conventions)

## 1. Purpose

Define exactly what every role can read/write, on every collection, in a form precise enough to translate directly into `firestore.rules`. This is what makes the "Firebase-only, zero Cloud Functions, zero cost" architecture actually safe: since there's no server validating writes, **the security rules are the entire trust boundary**.

## 2. Roles & How Role Is Determined

* Role lives on `users/{uid}/private/account.role` (`"resident"` | `"admin"` | `"superadmin"`) — **not** Firebase Auth Custom Claims. Custom claims can only be set by the Admin SDK (a server or a one-off script), which would either require a Cloud Function call reserved for that purpose or a manual script run per admin. Storing role as a plain Firestore field keeps role management entirely inside client-triggered, rules-enforced writes. It lives in the `private/account` subdocument (not the public `users/{uid}` doc) alongside `email`, `accountStatus`, and `fcmToken` — see `05_FIRESTORE_DATABASE.md` §3.2b for why (the public doc is broadly readable for the Resident Directory; the private one isn't).
* **Self-elevation is blocked by rule**, not by convention: a user may update their own `users/{uid}` (public) document, but never `buildingId`/`apartmentId` outside the approval flow; and on `users/{uid}/private/account`, a user may update `fcmToken` and `email` freely, may move `accountStatus` from `"active"` to `"deletion_requested"` only, and can **never** write `role` at all — that field is admin-write-only, always on someone else's document, never their own.

### 2.1 Bootstrapping the First Admin (no Cloud Function needed)

Because no user can grant themselves `role: "admin"`, the very first admin account per building must be created by the developer directly:

1. Create the user normally via the app's sign-up flow (they land as `role: "resident"`, unassigned).
2. Developer manually edits that one `users/{uid}` document in the Firebase Console, setting `role: "admin"` and `buildingId`.
3. From then on, that admin can promote/create further admins for their building through the app itself (an admin-only write path), with no console access needed again.

This is a one-time, per-building manual step — it happens outside the app and costs nothing.

## 3. Global Rules

* **Default deny.** Every collection not explicitly listed below is unreadable and unwritable: `match /{document=**} { allow read, write: if false; }` as the base, with explicit `match` blocks overriding it.
* **Building isolation is non-negotiable.** Every rule for a building-scoped collection must check `resource.data.buildingId == getUserBuilding(request.auth.uid)` (read) or `request.resource.data.buildingId == getUserBuilding(request.auth.uid)` (write), implemented as a reusable rules function that does one `get()` on the requester's public `users/{uid}` doc (`buildingId` lives there, not in the private subdoc — see `05_FIRESTORE_DATABASE.md` §3.2).
* **Admin check** is a second reusable function that needs two lookups: `isAdminOf(buildingId)` → `get(/databases/$(db)/documents/users/$(request.auth.uid)/private/account).data.role == "admin" && get(/databases/$(db)/documents/users/$(request.auth.uid)).data.buildingId == buildingId`. Two `get()` calls per admin check is well within Firestore rules' per-request limit (10).

### 3.1 Rules at a Glance

If you want the shortest mental model, the rules break into three patterns:

* **Owner-only docs** use the user's `uid` as the document ID, so only that same `uid` can read or write them.
* **Building-scoped docs** are readable by authenticated users in the same `buildingId`, and writable only by admins of that building.
* **Split public/private user docs** keep the resident directory simple while hiding `email`, `role`, `accountStatus`, and `fcmToken` in the private subdocument.

## 4. Why Anonymous Posts Need Two Collections (Recap)

See `05_FIRESTORE_DATABASE.md` §4 for the full rationale. In short: Firestore rules control access per-document, not per-field, so hiding `authorUid` from residents while still letting them read the rest of the post requires splitting the real author into a separate, admin-only-readable document (`post_authorship/{postId}`).

## 5. Collection-by-Collection Rules

### 5.1 `buildings/{buildingId}`

* Read: any authenticated user whose `users/{uid}.buildingId == buildingId`
* Write: admin of that building only (name/address/floor config edits)

### 5.2 `users/{uid}` (public profile)

* Read: the user themself; any admin of the same `buildingId`; **any resident whose own `buildingId` matches this document's `buildingId`** (this is what powers the Resident Directory — it's why sensitive fields live in §5.2b instead of here)
* Create: only the authenticated user creating their own doc (`request.auth.uid == uid`), with `buildingId`/`apartmentId` forced to `null` at creation — must happen in the same client transaction as creating `users/{uid}/private/account` (§5.2b), or the user ends up with a public profile and no role record
* Update:
  * Self-update allowed for `displayName`, `authProvider`, `photoUrl` freely
  * `buildingId`/`apartmentId` may only change via the admin-driven apartment-approval batch (`5.4`), never a standalone self-update
  * Admin-update allowed for `buildingId`/`apartmentId` on a **different** user's doc, scoped to the admin's own building
* Delete: never client-side (account deletion is a request-and-admin-action, not a raw delete — per `03_RESIDENT_SYSTEM.md` §6.7)

### 5.2b `users/{uid}/private/account`

* Read: the user themself only; admin of the user's `buildingId` (needed for the approval/removal/deletion workflows and for `isAdminOf()` lookups — note an admin reading another admin's private doc is harmless, there's nothing there a fellow admin shouldn't see)
* **Never** readable by a same-building resident who isn't the doc's owner or an admin — this is the entire reason the split exists (§4, and `05_FIRESTORE_DATABASE.md` §3.2b)
* Create: only by the owning user, in the same transaction as their public `users/{uid}` doc, with `role` forced to `"resident"` and `accountStatus` forced to `"active"` — no client can self-elevate at signup
* Update:
  * Self-update allowed for `fcmToken` (any value — this is the field written on every login and every `onTokenRefresh` event, see `14_APP_ARCHITECTURE.md` §6) and `email`
  * Self-update allowed for `accountStatus`: `"active" → "deletion_requested"` only — no other transition
  * `role` is admin-write-only, and only on a **different** user's document, scoped to the admin's own building (an admin can never write their own `role`, closing the self-elevation loophole entirely)
  * `accountStatus → "removed"` or `"removed" → "active"` is admin-write-only
* Delete: never client-side (a Cloud Function–driven cleanup, or the same admin batch that removes the resident from their apartment, is the only path — see `05_FIRESTORE_DATABASE.md` note; not built for MVP since account deletion is a manual admin action per `03_RESIDENT_SYSTEM.md` §6.7)

### 5.3 `apartments/{apartmentId}`

* Read: any authenticated resident/admin with matching `buildingId`
* Create/Update/Delete: admin of that building only
* **Guard:** an update setting `status == "occupied"` must simultaneously set a non-null `primaryResidentUid` — the rule rejects any write that sets `occupied` with `primaryResidentUid == null`, preventing the desynced state called out in `02_ADMIN_SYSTEM.md` §10.

### 5.4 `apartment_requests/{uid}`

* Doc ID must equal `request.auth.uid` on create — a resident can only ever create/target their own request document.
* **Create allowed only if:**
  * `get(/databases/$(db)/documents/users/$(request.auth.uid)).data.apartmentId == null` (blocks the duplicate-account case — this is the rule behind the warning snackbar in `03_RESIDENT_SYSTEM.md` §3)
  * No existing request document, OR the existing one has `status != "pending"` (blocks submitting a second request while one is already pending)
* Read: the requester themself; any admin of the request's `buildingId`
* Update (approve/reject): admin of the request's `buildingId` only. Approval must be done as a batched write alongside: `apartments/{apartmentId}.status → "occupied"` + `primaryResidentUid`, and `users/{uid}.buildingId` + `apartmentId`. All three writes happen from the admin's authenticated client in one Firestore batch (atomic, no Cloud Function required).

### 5.5 `posts/{postId}`

* Read: any authenticated user with matching `buildingId`
* Create:
  * `request.resource.data.buildingId == getUserBuilding(request.auth.uid)`
  * If `isAnonymous == false`: `authorUid == request.auth.uid`
  * If `isAnonymous == true`: `authorUid == null`
  * A corresponding `post_authorship/{postId}` document **must be created in the same batch** (rules can't enforce cross-collection atomicity directly, so this is also a client-implementation contract documented in `14_APP_ARCHITECTURE.md` — the repository method that creates a post always writes both documents in one `WriteBatch`)
* Update:
  * Author: `resource.data.authorUid == request.auth.uid` **OR** `get(/databases/$(db)/documents/post_authorship/$(postId)).data.authorUid == request.auth.uid` (covers the anonymous-author-edits-own-post case) — author may edit `text`, `category` only, never `isPinned`/`isLocked`/counters
  * Admin: may update `isPinned`, `isLocked` only (not `text`)
* Delete: same author check as Update, **or** admin of the post's `buildingId`

### 5.6 `post_authorship/{postId}`

* Read: admin of the post's `buildingId`; **or** the document's own `authorUid` (so the client can resolve "is this my anonymous post" for edit/delete permission checks)
* Create: only at the same time as the parent post, by the real author (`authorUid == request.auth.uid`)
* Update/Delete: never (immutable audit record)

### 5.7 `posts/{postId}/reactions/{uid}`

* Doc ID must equal `request.auth.uid`
* Read: any building member
* Create/Delete: only by the reacting user on their own doc ID
* Update: not allowed (toggle = delete + recreate, not edit)
* **Side effect contract:** the client increments/decrements `posts/{postId}.reactionCount` in the same batch as the reaction write (rules validate the counter only moved by exactly 1 in the correct direction)

### 5.8 `posts/{postId}/comments/{commentId}`

* Read: any building member
* Create: any building member, `authorUid == request.auth.uid`, post must not have `isLocked == true`
* Update/Delete: comment author, or the post's author, or admin
* **Side effect contract:** client increments/decrements `posts/{postId}.commentCount` in the same batch

### 5.9 `bookmarks/{uid_postId}`

* Doc ID must equal `${request.auth.uid}_${postId}`
* Read/Create/Delete: only the owning user, on their own doc ID
* Never readable by anyone else — bookmarks are private

### 5.10 `announcements/{announcementId}`

* Read: any building member
* Create/Update/Delete: admin of that building only

### 5.11 `polls/{pollId}`

* Read: any building member
* Create/Update (close)/Delete: admin of that building only

### 5.12 `polls/{pollId}/votes/{uid}`

* Doc ID must equal `request.auth.uid`
* Create: only if `polls/{pollId}.status == "active"` and no existing vote doc for this uid
* Update/Delete: never (vote is final)

### 5.13 `notifications/{notificationId}`

This is the collection that makes zero-cost real-time notifications possible without Cloud Functions.

* Create: any authenticated building member, **provided**:
  * `recipientUid`'s `users/{recipientUid}.buildingId` matches the sender's `buildingId` (checked via `get()`) — a resident can only ever notify someone in their own building
  * `category` is one of the five allowed values
  * Exception: `category == "announcement"` may only be created by an admin (residents cannot fabricate announcement notifications)
* Read/Update (mark-as-read)/Delete: only `recipientUid == request.auth.uid`

### 5.14 `conversations/{conversationId}`

* Doc ID must equal the sorted, underscore-joined pair of `participantUids`
* Create: `request.auth.uid` must be one of the 2 `participantUids`; the other participant must share the same `buildingId`, **or** be an admin of that building (admin↔resident chat allowed; resident↔resident cross-building blocked, per `03_RESIDENT_SYSTEM.md` §6.5)
* Read/Update (lastMessage preview): only the 2 participants

### 5.15 `conversations/{conversationId}/messages/{messageId}`

* Create: only a participant of the parent conversation, `senderUid == request.auth.uid`
* Read: only participants of the parent conversation
* Update/Delete: never (messages are immutable in MVP)

## 6. Permissions Matrix (Rules-Level Summary)

| Collection | Resident Read | Resident Write | Admin Read | Admin Write |
|---|---|---|---|---|
| buildings | own building | ✘ | own building | ✔ (own building) |
| users (public) | own building (directory) | self (profile fields only) | own building | apartment fields, own building |
| users/private/account | self only | fcmToken, email, self-deletion-request | self + own building | role, accountStatus, own building |
| apartments | own building | ✘ | own building | ✔ |
| apartment_requests | own doc | own doc (create only) | own building | approve/reject |
| posts | own building | own posts (create/edit/delete) | own building | pin/lock/delete any |
| post_authorship | own post only | ✘ (system contract) | own building | ✘ (immutable) |
| reactions/comments | own building | own reaction/comment | own building | delete any comment |
| bookmarks | own only | own only | ✘ | ✘ |
| announcements | own building | ✘ | own building | ✔ |
| polls/votes | own building | own vote | own building | ✔ |
| notifications | own only | create for same-building recipient | ✘ | create announcement-category |
| conversations/messages | own conversations | own conversations | ✘ | ✘ (admin uses same rules as a resident participant) |

Directory listing (`03_RESIDENT_SYSTEM.md` §6.6) reads `displayName`, `apartmentId` (resolved to apartment number), and `photoUrl` from the **public** `users/{uid}` doc only — this is exactly why `role`, `email`, `accountStatus`, and `fcmToken` were split into `users/{uid}/private/account` (§5.2b) rather than left on the same document.

## 7. Non-Functional Requirements

* Every rule above must be covered by the Firebase Emulator Suite's rules unit tests before merging — a rule change without a corresponding test is not considered complete.
* No rule may rely on `request.resource.data` for a field it doesn't also validate the type/range of (e.g., `category` must be checked against the literal allowed list, not just "is a string").

## 8. Notes

* This rules design still avoids Firebase Auth Custom Claims — `role` is a plain rules-checked field, not a claim — even though the project now runs on the **Blaze plan** for the single push-notification Cloud Function (`14_APP_ARCHITECTURE.md` §6). Every *write* path in this document remains a trusted client write validated by rules; the one Cloud Function only *reads* (`notifications` → recipient's `fcmToken` → FCM send) and never needs its own write permissions beyond clearing a stale token.
* The "same-batch" contracts (public+private user doc, post + post_authorship, reaction + counter, comment + counter) are enforced by rules checking the *resulting* state is internally consistent, not by rules literally requiring two writes — but the app's repository layer must always perform them together, or counters/records will drift. This is called out explicitly in `14_APP_ARCHITECTURE.md`.

## 9. Future Enhancements

* Migrate `role` from `users/{uid}/private/account` to Auth Custom Claims now that Cloud Functions exist anyway — removes the `get()` role lookup on every rule evaluation (minor read-cost optimization, not required for MVP correctness)
* Add App Check to block unauthorized clients from writing directly to Firestore, once mobile apps are published
* Rate-limit notification creation per user via the same Cloud Function that already exists for push-sending, if abuse is ever observed (low-risk at MVP scale of ~100–200 residents, so not built pre-emptively)
