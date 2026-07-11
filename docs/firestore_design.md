# NeighborHub Firestore Design

This file is the implementation guide for the Firebase backend. It turns the product scope into a practical Firestore setup you can build one step at a time.

It is aligned with the existing NeighborHub planning docs, especially:

- [docs/05_FIRESTORE_DATABASE.md](docs/05_FIRESTORE_DATABASE.md)
- [docs/06_FIREBASE_SECURITY.md](docs/06_FIREBASE_SECURITY.md)
- [docs/15_ADMIN_UI_FUNCTIONALITY_PLAN.md](docs/15_ADMIN_UI_FUNCTIONALITY_PLAN.md)

## 1. Design Goals

- Keep the schema flat and query-friendly.
- Scope every building-owned record with `buildingId`.
- Use deterministic document IDs where they prevent duplicates.
- Keep public resident data separate from private account data.
- Make security rules the real trust boundary.
- Avoid images/media in the MVP.

## 2. Panel Breakdown

NeighborHub has two Firebase-powered app surfaces:

- **Admin Panel**: building setup, apartment management, resident approval, moderation, announcements, polls, and analytics.
- **User Panel**: resident onboarding, feed, reactions, comments, bookmarks, chat, notifications, polls, and profile actions.

Both surfaces use the same Firestore collections and the same security rules. The difference is which documents each surface reads, writes, and presents in the UI.

### 2.1 Admin Panel Firebase Design

The admin surface mainly works with these collections and paths:

- `buildings` for building creation and settings
- `users` for resident directory and profile inspection
- `users/{uid}/private/account` for role, account state, and verification workflows
- `apartments` for apartment CRUD and occupancy management
- `apartment_requests` for approval/rejection queues
- `posts` for moderation, pinning, locking, and deleting
- `post_authorship` for anonymous-author review in admin views
- `announcements` for broadcasting building notices
- `polls` and `polls/{pollId}/votes/{uid}` for poll creation and results
- `notifications` for resident-facing broadcasts
- `conversations` and `messages` for chat oversight if needed in admin support flows

Admin panel data responsibilities:

- Seed and edit a building record
- Generate and manage apartment inventory
- Approve or reject apartment requests
- Bind a resident to an apartment
- Moderate the resident feed
- Publish announcements
- Create and close polls
- Review building-level metrics

### 2.2 User Panel Firebase Design

The resident surface mainly works with these collections and paths:

- `buildings` for selecting or validating the active building
- `users` for public resident profile and directory display
- `users/{uid}/private/account` for email, role, and account state
- `apartment_requests` for joining a building or apartment
- `posts` for feed reading and post creation
- `post_authorship` only indirectly, for self-edit/delete logic on anonymous posts
- `posts/{postId}/reactions/{uid}` for likes
- `posts/{postId}/comments/{commentId}` for comment threads
- `bookmarks` for personal saved posts
- `announcements` for read-only building notices
- `polls` and `polls/{pollId}/votes/{uid}` for voting and results
- `notifications` for the resident inbox
- `conversations` and `messages` for 1:1 chat

Resident panel data responsibilities:

- Sign up and join a building
- Apply for an apartment
- View feed and post anonymously or publicly
- React, comment, and bookmark posts
- Receive announcements and notifications
- Chat with residents and admins inside the same building
- Update profile and request account deletion

## 2. Core Data Model

### 2.1 Buildings

Collection: `buildings`

Document ID: `buildingId` or auto-ID, but use one consistent ID strategy across the project.

Fields:

- `name`
- `address`
- `totalFloors`
- `apartmentsPerFloor`
- `createdAt`

Use this as the root tenant record for every other building-scoped collection.

### 2.2 Users Public Profile

Collection: `users`

Document ID: Firebase Auth `uid`

Fields:

- `displayName`
- `authProvider`
- `photoUrl`
- `buildingId`
- `apartmentId`
- `createdAt`

Purpose:

- Resident directory
- Post/comment author display
- Building-scoped membership lookup

### 2.3 Users Private Account

Path: `users/{uid}/private/account`

Fields:

- `email`
- `role`
- `accountStatus`
- `fcmToken`
- `createdAt`

Purpose:

- Role management
- Account state
- Push token storage
- Sensitive data isolation

### 2.4 Apartments

Collection: `apartments`

Document ID: apartment ID or generated ID, but keep it stable for the selected apartment record.

Fields:

- `buildingId`
- `number`
- `floor`
- `description`
- `status`
- `primaryResidentUid`
- `updatedAt`

Status values:

- `vacant`
- `pending_approval`
- `occupied`
- `blocked`

### 2.5 Apartment Requests

Collection: `apartment_requests`

Document ID: requester's `uid`

Fields:

- `buildingId`
- `apartmentId`
- `familyNote`
- `status`
- `decidedBy`
- `createdAt`
- `decidedAt`

Status values:

- `pending`
- `approved`
- `rejected`

### 2.6 Posts

Collection: `posts`

Document ID: auto-ID

Fields:

- `buildingId`
- `authorUid`
- `isAnonymous`
- `category`
- `text`
- `isPinned`
- `isLocked`
- `reactionCount`
- `commentCount`
- `bookmarkCount`
- `createdAt`
- `updatedAt`

Category values:

- `discussion`
- `recommendation`
- `help`
- `service`

Anonymous post rule:

- Store `authorUid = null` in the public post when anonymous.

### 2.7 Post Authorship Audit

Collection: `post_authorship`

Document ID: same as `posts/{postId}`

Fields:

- `authorUid`
- `isAnonymous`
- `buildingId`
- `createdAt`

Purpose:

- Admin moderation visibility
- Anonymous post accountability

### 2.8 Reactions

Path: `posts/{postId}/reactions/{uid}`

Document ID: reacting user `uid`

Fields:

- `type`
- `createdAt`

MVP reaction type:

- `like`

### 2.9 Comments

Path: `posts/{postId}/comments/{commentId}`

Document ID: auto-ID

Fields:

- `authorUid`
- `text`
- `createdAt`

### 2.10 Bookmarks

Collection: `bookmarks`

Document ID: `${uid}_${postId}`

Fields:

- `uid`
- `postId`
- `buildingId`
- `createdAt`

### 2.11 Announcements

Collection: `announcements`

Document ID: auto-ID

Fields:

- `buildingId`
- `title`
- `body`
- `createdBy`
- `createdAt`

### 2.12 Polls

Collection: `polls`

Document ID: auto-ID

Fields:

- `buildingId`
- `question`
- `options`
- `status`
- `createdBy`
- `createdAt`
- `closesAt`

Poll status values:

- `active`
- `closed`

Each option should store:

- `id`
- `text`
- `voteCount`

### 2.13 Poll Votes

Path: `polls/{pollId}/votes/{uid}`

Document ID: voter `uid`

Fields:

- `optionId`
- `createdAt`

### 2.14 Notifications

Collection: `notifications`

Document ID: auto-ID

Fields:

- `recipientUid`
- `buildingId`
- `category`
- `title`
- `body`
- `relatedPostId`
- `relatedConversationId`
- `isRead`
- `createdAt`

Category values:

- `announcement`
- `chat`
- `reaction`
- `comment`
- `poll`

### 2.15 Conversations

Collection: `conversations`

Document ID: sorted pair of participant UIDs joined with `_`

Fields:

- `buildingId`
- `participantUids`
- `lastMessage`
- `lastMessageAt`
- `createdAt`

### 2.16 Conversation Messages

Path: `conversations/{conversationId}/messages/{messageId}`

Document ID: auto-ID

Fields:

- `senderUid`
- `text`
- `createdAt`

## 3. Suggested Build Order

Build the Firebase backend in this order so every later screen has the data it needs.

1. `buildings`
2. `users` public profile
3. `users/{uid}/private/account`
4. `apartments`
5. `apartment_requests`
6. `posts` and `post_authorship`
7. `reactions`, `comments`, `bookmarks`
8. `announcements`
9. `polls` and `votes`
10. `notifications`
11. `conversations` and `messages`

## 4. Security Rules Summary

These are the rule principles the implementation should follow.

### 4.1 Global Rules

- Default deny every collection that is not explicitly allowed.
- Every building-scoped read/write must verify `buildingId`.
- Admin access must be checked separately from resident access.
- Do not rely on client trust for sensitive state.

### 4.2 Public Profile Rules

`users/{uid}`

- Read: same-building residents, same-building admins, and the owner.
- Create: only the owner.
- Update: owner may change profile fields only.
- Admin may update apartment-binding fields during approval.

### 4.3 Private Account Rules

`users/{uid}/private/account`

- Read: owner and same-building admin.
- Create: only the owner.
- Update: owner may update `email`, `fcmToken`, and self-deletion request state.
- `role` is admin-only.

### 4.4 Apartments Rules

`apartments/{apartmentId}`

- Read: authenticated users in the same building.
- Write: building admin only.
- If `status` becomes `occupied`, `primaryResidentUid` must be present.

### 4.5 Apartment Request Rules

`apartment_requests/{uid}`

- Document ID must match the requester `uid`.
- A resident can create only their own request.
- An already assigned user should not be allowed to create a new request.
- Approval/rejection is admin-only.

### 4.6 Post Rules

`posts/{postId}`

- Read: authenticated users in the same building.
- Create: `buildingId` must match the writer’s building.
- Anonymous posts must store `authorUid = null` publicly.
- Editing and moderation should be separated between author and admin permissions.

### 4.7 Post Authorship Rules

`post_authorship/{postId}`

- Read: admin of the building or the original author.
- Create: only as part of the post-creation batch.
- Update/delete: never.

### 4.8 Reactions and Comments

- Reactions are one per user per post.
- Comments are always attributed.
- Counters on the parent post must stay in sync with child writes.

### 4.9 Bookmarks Rules

- Bookmarks are private to the owner.
- No other resident or admin should need access.

### 4.10 Announcement, Poll, Notification, and Chat Rules

- Announcements: admin-only write.
- Polls: admin-only create/update/close.
- Votes: one vote per user per poll.
- Notifications: recipient-only read/update.
- Conversations/messages: only the two participants can access them.

## 5. Firestore Indexes To Create

Create these indexes when the relevant queries are added:

- `apartments`: `buildingId`, `status`
- `posts`: `buildingId`, `createdAt desc`
- `posts`: `buildingId`, `category`, `createdAt desc`
- `notifications`: `recipientUid`, `isRead`, `createdAt desc`
- `conversations`: `participantUids` array-contains, `buildingId`

## 6. Recommended Implementation Notes

- Keep every write that needs multiple documents in a single batch.
- Use the same collection and field names in Flutter models, repository code, and security rules.
- Keep timestamps as Firestore timestamps, not strings.
- Do not add media fields in MVP.
- Keep anonymous posts private in the public collection and auditable in `post_authorship`.

## 7. Step-By-Step Firebase Setup

If you want to build this one layer at a time, use this order:

1. Create the Firestore collections and seed one building.
2. Add the user profile flow and private account document.
3. Add apartment creation and apartment listing.
4. Add apartment request submission and admin approval.
5. Add posts, anonymous posting, and moderation support.
6. Add reactions, comments, and bookmarks.
7. Add announcements and poll management.
8. Add notifications.
9. Add chat collections.
10. Lock everything down with Firestore security rules and emulator tests.

## 8. Reference Rule

When in doubt, keep the schema simple and let the rules enforce who can see or change each record.
