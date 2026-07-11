# 03_RESIDENT_SYSTEM.md

# NeighborHub — Resident (User) System

**Version:** 0.1 (Planning Phase)
**Applies to:** Resident Mobile App

## 1. Purpose

Define every interaction a Resident (the end user) has with NeighborHub — from joining a building to posting, chatting, and managing their account. This document is self-contained: a developer building any resident-facing feature should be able to work from this file alone.

## 2. Scope

### Included (MVP)

* Account model: one Primary Resident Account per apartment
* Authentication (Email/Password, Google Sign-In)
* Apartment join / approval flow
* Feed: create post, react, comment, bookmark
* Post categories: Discussion, Recommendation, Help, Service
* Anonymous posting
* Announcements (read-only)
* Notifications (categorized)
* Chat (1:1, building-scoped)
* Resident Directory
* Polls (vote + view results)
* Profile management + account deletion request
* Offline-friendly post creation

### Excluded (MVP)

* Buying/Selling post category (deliberately excluded — avoids image requirement)
* Image, video, or voice attachments
* Group chat
* Cross-building interaction of any kind

## 3. Account Model

**One Apartment → One Primary Resident Account.**

* Each apartment has exactly one active account holder: the Primary Resident.
* The Primary Resident is treated as the accountable identity for that apartment (posts, chats, moderation all trace back to this account).
* **Duplicate prevention:** A user (by auth UID) may hold only one Primary Resident Account per building. If a signed-in user without an apartment tries to submit a second apartment request while already bound to an apartment, the client blocks the action and shows a warning snackbar: *"You already have a resident account for this building."* This is enforced both client-side (UX) and via Firestore Security Rules (source of truth).
* **Future (Phase 2+):** Additional Members under a Primary Resident (e.g., spouse, adult child) with shared or restricted permissions. Not built in MVP — data model should not block this later, but no UI/logic for it exists now.

## 4. Authentication

* Sign in with **Email/Password** or **Google Sign-In**
* If signed in via Google: profile photo from Google account is used as the avatar wherever identity is shown (feed, directory, chat).
* If signed in via Email/Password (no Google photo available): a default **person icon** is shown instead. No custom avatar upload in MVP (no media storage).
* Anonymous posts always show a generic "Anonymous Resident" icon/label regardless of the poster's actual login method.

## 5. Onboarding & Apartment Join Flow

1. Resident signs up / signs in
2. Selects their building (from available buildings, or via invite/building code — mechanism TBD in Firebase Architecture doc)
3. Views list of `Vacant` apartments
4. Submits apartment request (name, optional family member note, optional description)
5. Apartment status becomes `Pending Approval`
6. Resident sees a "Waiting for Admin Approval" state — no feed/chat access yet
7. Admin approves → apartment becomes `Occupied`, resident account activated → resident lands on full Dashboard (Feed)
8. Admin rejects → resident notified, apartment returns to `Vacant`, resident can apply elsewhere

## 6. Core Features

### 6.1 Feed

* View building feed (posts from all residents in the same building only)
* Create a post with:
  * **Category** (required conceptually, but see Anonymous rule below): `Discussion`, `Recommendation`, `Help`, `Service`
  * Text content
  * **Post Anonymously** checkbox
* **Anonymous logic:**
  * If the resident checks "Post Anonymously" → post displays as "Anonymous Resident" with no name/avatar/apartment shown.
  * If the resident does not select a category at all (unsure how to classify their post) → the post is **also treated as anonymous by default**. This keeps the UX simple: uncategorized = anonymous, no forced decision paralysis.
  * In all cases, the real `authorId` is stored in Firestore for Admin moderation — never exposed to other residents.
* Text-only posts — no image/video (product decision, keeps implementation and moderation simple; see `00_PROJECT_OVERVIEW.md`)

### 6.2 Post Interactions

* **React** (like-style reaction) — one reaction per resident per post, toggleable
* **Comment** — text-only, real-time thread under the post
* **Bookmark** — save post to a personal bookmarks list, private to the resident
* Reactions, comments, and bookmarks all update **live** via Firestore listeners — a resident sees the count change without refreshing (real-life UX requirement).
* **Author-only:** edit/delete own post, edit/delete own comment.
* Residents **cannot** edit or delete others' content; only Admin can (see `02_ADMIN_SYSTEM.md`).

### 6.3 Announcements

* Read-only feed of building-wide announcements from Admin
* Cannot react/comment on announcements in MVP (announcements are informational, not conversational) — open to revisit in Phase 2 if needed

### 6.4 Notifications

Categorized so residents can filter instead of seeing one noisy stream:

| Category | Trigger |
|---|---|
| 🔴 Announcements | Admin publishes an announcement/notice |
| 💬 Chat | New message received |
| ❤️ Reactions | Someone reacts to the resident's post |
| 💭 Comments | Someone comments on the resident's post |
| 📊 Polls | New poll created / poll closing soon / results available |

* Reacting to a post triggers an **immediate** notification to the post's author (real-time, not batched) — this is core to the "real life UX" goal.
* Resident can filter the notification list by category.

### 6.5 Chat

* Chat icon on the main navigation opens the **Chat List**.
* **Initial state:** empty ("No conversations yet — start one from the Resident Directory").
* Starting a new chat: `+ New Chat` → **Resident Directory** → select a resident → opens (or reuses, if it already exists) a 1:1 **Conversation** between exactly those two participants.
* **Chat permissions:**
  * Resident ↔ Admin: ✔ allowed
  * Resident ↔ Resident, same building: ✔ allowed
  * Resident ↔ Resident, different building: ✘ not allowed (Resident Directory only ever lists same-building residents; this is also enforced server-side)
* Messages, read state, and chat list ordering update in real time via Firestore listeners.
* No group chat, no media messages, no typing indicator in MVP.

### 6.6 Resident Directory

* Lists all residents in the resident's own building: name + apartment number
* Tapping a resident opens a minimal profile → **Start Chat** action
* This is the only entry point for starting a new conversation (mirrors "tap a contact to message" pattern)

### 6.7 Profile

* View/update own profile info (name, contact preference fields — no building/apartment field editing by resident, that's admin-controlled)
* **Request Account Deletion:** resident submits a deletion request; this is a request, not an instant self-service delete, since it also needs to free the apartment back to `Vacant` on the admin side. Flow: `Resident requests deletion` → `Admin notified` → `Admin confirms/removes resident` → `Apartment status → Vacant` → `Account deactivated`.

### 6.8 Polls

* View active polls in the building feed
* Vote once per poll
* View live/final results after voting or after poll closes

## 7. Permissions Summary

| Action | Allowed? |
|---|---|
| Read posts/announcements in own building | ✔ |
| React, comment, bookmark on any post in own building | ✔ |
| Edit/delete own post or comment | ✔ |
| Edit/delete another resident's post or comment | ✘ |
| Chat with Admin | ✔ |
| Chat with resident in same building | ✔ |
| Chat with resident in a different building | ✘ |
| See real identity behind an anonymous post | ✘ (Admin only) |
| Create more than one Primary Resident Account per apartment/building | ✘ (blocked, warning snackbar) |

## 8. Offline Behavior

* Firestore's offline persistence is relied on rather than a custom sync layer.
* If a resident creates a post/comment/reaction while offline, it is queued locally and automatically written to Firestore once connectivity returns — no explicit "retry" action needed from the user.
* Feed/chat screens should read from Firestore's local cache first so the app never shows a blank state purely due to a dropped connection.

## 9. User Stories

* As a resident, I want to post anonymously when I'm unsure how my post will be received.
* As a resident, I want to get notified immediately when someone reacts to my post, so it feels alive.
* As a resident, I want to start a chat directly from the resident directory, like messaging a contact.
* As a resident, I want my feed and chats to keep working even with a brief network drop.
* As a resident, I want to request account deletion without needing to email support.

## 10. Acceptance Criteria

* A post with no category selected and no explicit anonymous checkbox still renders as "Anonymous Resident" in the feed.
* A reaction on a post fires a notification to the author within the same real-time session (no manual refresh required).
* A resident cannot see or start a chat with a resident from another building — the Resident Directory query itself is building-scoped.
* Attempting a second apartment request while already bound to one shows a snackbar and does not create a new request document.

## 11. Notes

* Buying/Selling was deliberately excluded from post categories because it implies photos of items, which conflicts with the no-media principle.
* The account model intentionally supports only a Primary Resident in MVP but the data model should not preclude adding Additional Members later.

## 12. Future Enhancements

* Additional Members per apartment (spouse, adult children) with shared or scoped permissions
* Internal post sharing (Phase 2, "Share internally" within the same building)
* Typing indicators and read receipts in chat
* Push-notification deep-linking directly into the relevant post/chat
* Self-service instant account deletion (no admin step) once apartment-state automation is trusted
