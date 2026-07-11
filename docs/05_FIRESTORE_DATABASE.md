# 05_FIRESTORE_DATABASE.md

# NeighborHub — Firestore Database Schema

**Version:** 0.1 (Planning Phase)
**Depends on:** `02_ADMIN_SYSTEM.md`, `03_RESIDENT_SYSTEM.md`, `10_DATA_FLOW_DIAGRAM.md`

## 1. Purpose

Define every Firestore collection, document shape, field, and relationship in NeighborHub, so any developer or coding agent can implement data access without guessing field names or structure. This is the single source of truth for the database — `06_FIREBASE_SECURITY.md` and `14_APP_ARCHITECTURE.md` both build directly on the structure defined here.

## 2. Design Approach

* **Single building MVP.** For now the project targets one building only, so every building-scoped document should use the same project-wide `buildingId` value. The app should fill this in automatically when creating documents.
* **Top-level collections, not deep nesting.** Every building-scoped document carries a `buildingId` field rather than living under `buildings/{buildingId}/...`. This keeps queries simple (e.g., "all posts in building X" is a flat `where('buildingId', '==', x)` query) and avoids Firestore's collection-group query complexity.
* **No images/media fields anywhere** — consistent with the product's no-media principle.
* **Denormalized counters** (`reactionCount`, `commentCount`, etc.) are stored directly on parent documents so feed/list screens never need to fan out into subcollections just to render a count.
* **Deterministic document IDs** are used wherever they prevent duplicates or simplify security rules (see each collection below) — this avoids needing Cloud Functions to enforce uniqueness.

### 2.1 Firestore Tree at a Glance

```mermaid
graph TD
	A[buildings/{buildingId}\nRead: building members\nWrite: building admins]
	B[users/{uid}\nPublic profile\nRead: same-building residents + admins + owner\nWrite: owner fields only, or admins for apartment assignment]
	C[users/{uid}/private/account\nPrivate account data\nRead: owner + building admins\nWrite: owner email/fcmToken, admins role/accountStatus]
	D[apartments/{apartmentId}\nRead: building members\nWrite: building admins]
	E[apartment_requests/{uid}\nRead: requester + building admins\nWrite: requester create, admins approve/reject]
	F[posts/{postId}\nRead: building members\nWrite: post author, or admins for pin/lock]
	G[post_authorship/{postId}\nRead: post author + building admins\nWrite: create with post only\nImmutable after create]
	H[posts/{postId}/reactions/{uid}\nRead: building members\nWrite: reaction owner only]
	I[posts/{postId}/comments/{commentId}\nRead: building members\nWrite: comment author, post author, or admins]
	J[bookmarks/{uid_postId}\nRead/Write: owner only]
	K[announcements/{announcementId}\nRead: building members\nWrite: building admins]
	L[polls/{pollId}\nRead: building members\nWrite: building admins]
	M[polls/{pollId}/votes/{uid}\nRead: building members\nWrite: voter only, once]
	N[notifications/{notificationId}\nRead/Write: recipient only\nCreate: sender in same building]
	O[conversations/{conversationId}\nRead/Write: the 2 participants]
	P[conversations/{conversationId}/messages/{messageId}\nRead/Write: the 2 participants]

	B --> C
	F --> G
	F --> H
	F --> I
	L --> M
	O --> P
```

Simple reading guide:

* **Public data** lives in `users/{uid}` because it is safe for the resident directory and post author display.
* **Private data** lives in `users/{uid}/private/account` because it contains `email`, `role`, `accountStatus`, and `fcmToken`.
* **Building-scoped data** keeps a `buildingId` field so rules can check one building boundary consistently.
* **Owner-scoped data** uses the authenticated user's `uid` as the document ID so rules can stay simple and deterministic.

## 3. Collections

### 3.1 `buildings/{buildingId}`

| Field | Type | Notes |
|---|---|---|
| `name` | string | |
| `address` | string | |
| `totalFloors` | number | |
| `apartmentsPerFloor` | number | |
| `createdAt` | timestamp | |

### 3.2 `users/{uid}` (public profile)

`uid` = Firebase Auth UID. One document per authenticated person (resident or admin). Holds only what other same-building residents legitimately need to see (Resident Directory, post/comment authorship, chat participant info). Anything sensitive lives in the private subdocument below — same public/private split pattern used for anonymous post authorship (§4).

| Field | Type | Notes |
|---|---|---|
| `displayName` | string | |
| `authProvider` | string | `"google"` \| `"password"` — determines avatar fallback per `04_UI_UX_GUIDELINES.md` |
| `photoUrl` | string \| null | Only populated when `authProvider == "google"` |
| `buildingId` | string \| null | Set on apartment approval; null while unassigned. Kept on the public doc (not private) because it's the field every building-scoped query filters on, including the Resident Directory listing itself. |
| `apartmentId` | string \| null | Set on apartment approval; this is what makes a user the **Primary Resident** of that apartment |
| `createdAt` | timestamp | |

**Note:** A user is a Primary Resident Account holder if and only if `apartmentId != null`. There is no separate "resident" document — `users/{uid}` IS the resident record.

### 3.2b `users/{uid}/private/account`

Single subdocument per user holding everything other residents should never read — split out specifically because the Resident Directory needs broad read access to `users/{uid}` itself.

| Field | Type | Notes |
|---|---|---|
| `email` | string | |
| `role` | string | `"resident"` \| `"admin"` \| `"superadmin"` (superadmin reserved, unused in MVP) |
| `accountStatus` | string | `"active"` \| `"deletion_requested"` \| `"removed"` |
| `fcmToken` | string \| null | Current FCM registration token for this device — used to target push notifications when the recipient's app is backgrounded/killed (see `14_APP_ARCHITECTURE.md` §6). Written at login/app-start **and** on every Firebase `onTokenRefresh` event, since tokens rotate — never just once at account creation. |
| `createdAt` | timestamp | |

**One token per user = one actively-notified device.** Logging in on a new device overwrites the token; the previous device stops receiving pushes. This is a deliberate MVP simplification consistent with the one-Primary-Resident-Account model — multi-device support (an array of tokens) is a Future Enhancement (§8), not a bug to "fix" mid-build.

**Why `fcmToken` isn't on the public doc:** a device token alone can't be used to send a push without also holding the project's Firebase service-account credentials (which only the Cloud Function has), so it isn't a secret in the strict sense — but there's no reason to hand it to every neighbor either, so it sits alongside `role` and `email` in the private subdocument instead.

### 3.3 `apartments/{apartmentId}`

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `number` | string | e.g. `"A-302"` |
| `floor` | number | |
| `description` | string \| null | |
| `status` | string | `"vacant"` \| `"pending_approval"` \| `"occupied"` \| `"blocked"` |
| `primaryResidentUid` | string \| null | Set when `status == "occupied"`; mirrors `users/{uid}.apartmentId` |
| `updatedAt` | timestamp | |

### 3.4 `apartment_requests/{uid}`

**Document ID = requester's `uid`** (not an auto-ID). This is a deliberate design choice: it gives each resident exactly one request record, makes "does this user already have a pending/active request" a single cheap `get()` instead of a query, and is what powers the duplicate-account warning snackbar at the security-rules layer (see `06_FIREBASE_SECURITY.md`).

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `apartmentId` | string | Apartment being requested |
| `familyNote` | string \| null | Optional free text (e.g., "2 adults") |
| `status` | string | `"pending"` \| `"approved"` \| `"rejected"` |
| `decidedBy` | string \| null | Admin `uid` |
| `createdAt` | timestamp | |
| `decidedAt` | timestamp \| null | |

### 3.5 `posts/{postId}`

The public-facing post document — this is what every resident's feed listener reads.

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `authorUid` | string \| null | **Null when the post is anonymous.** Populated with the real `uid` only for non-anonymous posts. See §4 for why. |
| `isAnonymous` | boolean | True if the checkbox was set, OR no category was selected (per `03_RESIDENT_SYSTEM.md` §6.1 default rule) |
| `category` | string \| null | `"discussion"` \| `"recommendation"` \| `"help"` \| `"service"` \| `null` |
| `text` | string | |
| `isPinned` | boolean | Admin-only field |
| `isLocked` | boolean | Admin-only field — blocks new comments when true |
| `reactionCount` | number | Denormalized |
| `commentCount` | number | Denormalized |
| `bookmarkCount` | number | Denormalized |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |

### 3.6 `post_authorship/{postId}` (admin-only collection)

Holds the **real** author of every post, including anonymous ones. This is the mechanism that satisfies "Admin still knows the author internally for moderation" without needing a Cloud Function or field-level read redaction (Firestore can't partially hide fields within one document — see `06_FIREBASE_SECURITY.md` §4 for the full rationale).

| Field | Type | Notes |
|---|---|---|
| `authorUid` | string | Always the real author, regardless of `isAnonymous` |
| `isAnonymous` | boolean | Mirrors the post |
| `buildingId` | string | For rule scoping |
| `createdAt` | timestamp | |

Written once at post creation (same client batch/transaction as `posts/{postId}`), never updated.

### 3.7 `posts/{postId}/reactions/{uid}`

**Document ID = reacting user's `uid`.** Guarantees one reaction per user per post — no query needed to enforce this.

`postId` comes from the parent path `posts/{postId}` when you create the subcollection document. You do not type it twice.

| Field | Type | Notes |
|---|---|---|
| `type` | string | `"like"` (single reaction type for MVP) |
| `createdAt` | timestamp | |

### 3.8 `posts/{postId}/comments/{commentId}`

Comments are **always attributed** — anonymity applies to posts only, not comments (deliberate MVP simplification; see Notes).

`commentId` is an auto-ID, so the app can create comments without manually choosing an ID.

| Field | Type | Notes |
|---|---|---|
| `authorUid` | string | Always real, always visible |
| `text` | string | |
| `createdAt` | timestamp | |

### 3.9 `bookmarks/{uid_postId}`

**Document ID = `${uid}_${postId}`.** Private to the owning user.

| Field | Type | Notes |
|---|---|---|
| `uid` | string | |
| `postId` | string | |
| `buildingId` | string | |
| `createdAt` | timestamp | |

### 3.10 `announcements/{announcementId}`

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `title` | string | |
| `body` | string | |
| `createdBy` | string | Admin `uid` |
| `createdAt` | timestamp | |

### 3.11 `polls/{pollId}`

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `question` | string | |
| `options` | array<map> | `[{ id, text, voteCount }]` — `voteCount` denormalized |
| `status` | string | `"active"` \| `"closed"` |
| `createdBy` | string | Admin `uid` |
| `createdAt` | timestamp | |
| `closesAt` | timestamp \| null | |

### 3.12 `polls/{pollId}/votes/{uid}`

**Document ID = voter's `uid`.** One vote per resident, immutable (no update/delete — a vote is final for MVP).

`pollId` comes from the parent poll path. `uid` comes from the signed-in Firebase Auth user, so the app gets it from `request.auth.uid` on the client side.

| Field | Type | Notes |
|---|---|---|
| `optionId` | string | |
| `createdAt` | timestamp | |

### 3.13 `notifications/{notificationId}`

Written **directly by clients** (not by a Cloud Function) — this is the zero-cost notification design. See `14_APP_ARCHITECTURE.md` §6.

| Field | Type | Notes |
|---|---|---|
| `recipientUid` | string | |
| `buildingId` | string | |
| `category` | string | `"announcement"` \| `"chat"` \| `"reaction"` \| `"comment"` \| `"poll"` |
| `title` | string | |
| `body` | string | |
| `relatedPostId` | string \| null | For deep-linking |
| `relatedConversationId` | string \| null | For deep-linking |
| `isRead` | boolean | |
| `createdAt` | timestamp | |

### 3.14 `conversations/{conversationId}`

**Document ID = the two participant UIDs, sorted and joined:** `${sortedUid1}_${sortedUid2}`. This makes "does a conversation already exist between A and B" a single `get()` instead of a query, and structurally prevents duplicate conversations between the same pair.

| Field | Type | Notes |
|---|---|---|
| `buildingId` | string | |
| `participantUids` | array<string> | Always exactly 2 |
| `lastMessage` | string | Denormalized preview |
| `lastMessageAt` | timestamp | |
| `createdAt` | timestamp | |

### 3.15 `conversations/{conversationId}/messages/{messageId}`

| Field | Type | Notes |
|---|---|---|
| `senderUid` | string | |
| `text` | string | |
| `createdAt` | timestamp | |

## 4. Key Design Decision: Anonymous Posts Without Cloud Functions

Firestore security rules cannot hide individual fields within a document from a reader who's allowed to read that document at all — access control is document-level, not field-level. So a single `posts/{postId}` document cannot both (a) be readable by every resident in the building and (b) hide `authorUid` from everyone except admins.

**Solution:** split into two documents, written together at post-creation time by the client:

* `posts/{postId}` — the field `authorUid` is only populated when `isAnonymous == false`. When anonymous, it's `null`, so there is nothing to leak to residents even though they can read the whole document.
* `post_authorship/{postId}` — always has the real `authorUid`, but this collection's security rule only allows reads by admins of that building (and by the original author themself, so they can still edit/delete their own anonymous post — see `06_FIREBASE_SECURITY.md` §5.4).

This gets true anonymity from other residents, full accountability for admins, and author-editability for anonymous posts — all enforced by Firestore rules alone, with zero server-side code.

## 5. Indexes Required

* `apartments`: composite on (`buildingId`, `status`)
* `posts`: composite on (`buildingId`, `createdAt` desc), and (`buildingId`, `category`, `createdAt` desc)
* `notifications`: composite on (`recipientUid`, `isRead`, `createdAt` desc)
* `conversations`: composite on (`participantUids` array-contains, `buildingId`)
* `apartment_requests`: none needed beyond default — doc ID lookups only (§3.4)

## 6. Naming Conventions

* Collection names: plural, snake_case where multi-word (`apartment_requests`, `post_authorship`)
* Field names: camelCase
* Every building-scoped document has a `buildingId` field — no exceptions, even where it could be derived indirectly, since it's required for security rule scoping and simple queries.
* Timestamps always use Firestore `Timestamp`, never client-generated strings.

## 7. Notes

* Comments are intentionally never anonymous — anonymity is scoped to the post-creation moment only, keeping the comment thread model simple and matching the product's minimal-complexity principle.
* This schema has **zero fields or collections related to images/media**, by design.
* `post_authorship` and `notifications` are both written directly by clients, validated purely by security rules — no server logic needed to create them. The one Cloud Function in the system (`14_APP_ARCHITECTURE.md` §6) only *reads* `notifications` after the fact to send a push; it never needs to be trusted with a write path.

## 8. Future Enhancements

* `users/{uid}/private/account.fcmToken` → array of `{ token, deviceLabel, updatedAt }` for multi-device push support
* `users/{uid}.additionalMembers` (array or subcollection) when multi-member-per-apartment ships (see `03_RESIDENT_SYSTEM.md` §12)
* `posts/{postId}.sharedFrom` field for internal Phase 2 sharing
* `messages/{messageId}.readBy` map if read receipts are added
