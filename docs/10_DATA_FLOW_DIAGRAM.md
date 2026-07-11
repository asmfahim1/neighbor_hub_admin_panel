# 10_DATA_FLOW_DIAGRAM.md

# NeighborHub — Data Flow Diagrams

**Version:** 0.1 (Planning Phase)

## 1. Purpose

Show, visually and step-by-step, how data moves through NeighborHub for every core behavior — so a developer can understand *system behavior*, not just data structure. Read alongside `02_ADMIN_SYSTEM.md` and `03_RESIDENT_SYSTEM.md` for the "why" behind each step.

## 2. Scope

Covers the following flows:

1. Resident Onboarding & Apartment Approval
2. Create Post → Feed Update (including Anonymous branch)
3. Reaction/Comment → Real-Time Notification
4. Chat: Start Conversation → Message Delivery
5. Admin Moderation
6. Apartment Status Lifecycle
7. Offline Post Creation → Sync

## 3. Flow 1 — Resident Onboarding & Apartment Approval

```
Resident opens app
      ↓
Authentication (Email/Password or Google)
      ↓
Select Building
      ↓
View Vacant Apartments
      ↓
Submit Apartment Request
      ↓
[System check] Does this user already hold a Primary Resident
Account in this building?
      ├── YES → Block request, show warning snackbar, STOP
      └── NO  → Continue
      ↓
Apartment status → Pending Approval
      ↓
Admin reviews request (App or Web Portal)
      ├── Reject → Apartment status → Vacant, resident notified
      └── Approve ↓
      ↓
Apartment status → Occupied
      ↓
Resident account activated (bound to apartment)
      ↓
Resident receives Announcement-style notification of approval
      ↓
Resident lands on Feed (full access)
```

## 4. Flow 2 — Create Post → Feed Update

```
Resident opens Create Post
      ↓
Selects Category (Discussion / Recommendation / Help / Service)
   — or leaves uncategorized —
      ↓
Toggles "Post Anonymously" (optional)
      ↓
[Client logic] Anonymous if: checkbox is ON, OR no category selected
      ↓
Post written to Firestore
   - authorId always stored (real identity, even if anonymous)
   - isAnonymous flag stored
   - category stored (nullable)
      ↓
Firestore document created in building-scoped posts collection
      ↓
Realtime snapshot listener fires for all residents currently
viewing the Feed in that building
      ↓
Feed updates instantly for every connected resident
(no manual refresh)
```

## 5. Flow 3 — Reaction/Comment → Real-Time Notification

```
Resident B reacts to (or comments on) Resident A's post
      ↓
Client writes 2 documents in one batch:
   - Reaction/Comment document (posts/{postId}/reactions or
     /comments)
   - Notification document for Resident A
     (recipientUid: A, category: "reaction" or "comment")
      ↓
Three things happen, not strictly in order:
   ├── Resident A's Notifications screen (if open) updates
   │   instantly via Firestore listener — no server involved
   ├── Post's reactionCount/commentCount updates live for every
   │   viewer of the Feed — also no server involved
   └── Cloud Function triggers on the new Notification document:
         reads Resident A's fcmToken (users/{A}/private/account)
              ↓
         calls FCM send() → push delivered even if Resident A's
         app is backgrounded or fully closed
              ↓
         (if token is stale/unregistered, Function clears it)
      ↓
Resident A taps notification (in-app or OS push) → deep-links to
the specific post
```

*Note: reaction/comment/bookmark counts on the post itself are also live-streamed via Firestore listeners directly to every viewer's Feed — the notification path above is specifically about alerting the post's author, separate from the count updating for everyone else watching the feed.*

## 6. Flow 4 — Chat: Start Conversation → Message Delivery

```
Resident taps Chat icon
      ↓
Chat List loads (empty on first use)
      ↓
Resident taps "+ New Chat"
      ↓
Resident Directory opens (building-scoped query — only same-
building residents + admin are ever returned)
      ↓
Resident selects a target resident
      ↓
[System check] Does a conversation between these 2 participants
already exist?
      ├── YES → Open existing conversation
      └── NO  → Create new conversation document (participants:
                [A, B]) → Open it
      ↓
Resident sends a message
      ↓
Client writes 2 documents in one batch:
   - Message document (subcollection of conversation)
   - Notification document for the receiver (category: "chat")
      ↓
Receiver's Chat List + open Conversation screen update live via
Firestore listener (foreground/background-alive case)
      ↓
Cloud Function triggers on the new Notification document → reads
receiver's fcmToken → FCM push sent (covers the fully-closed-app
case; same mechanism as Flow 3)
      ↓
Receiver taps notification (in-app or OS push) → deep-links into
the Conversation
```

**Cross-building block:** Because the Resident Directory query is always scoped to `building_id == current_user.building_id`, a resident physically cannot select a resident from another building — this is also enforced server-side via Firestore Security Rules on the conversation-create write (both participants must share `building_id`, unless one participant is that building's Admin).

## 7. Flow 5 — Admin Moderation

```
Admin opens Feed Moderation view (App or Web Portal)
      ↓
Admin sees all posts, including real author identity behind
anonymous posts (moderation-only view)
      ↓
Admin chooses an action: Delete / Lock Comments / Pin
      ↓
Firestore document updated or deleted
      ↓
Realtime listener propagates the change to every resident
currently viewing the Feed
      ↓
(If Delete) Post disappears from all feeds instantly
(If Lock) Existing comments remain, new comment input disabled
(If Pin) Post moves to top of Feed for all residents
```

## 8. Flow 6 — Apartment Status Lifecycle

```
        ┌────────────┐   request submitted    ┌───────────────────┐
        │   Vacant   │ ─────────────────────▶ │ Pending Approval   │
        └────────────┘                        └───────────────────┘
              ▲                                    │        │
              │ resident removed /                 │reject  │approve
              │ deletion approved                  ▼        ▼
              │                              (back to    ┌──────────┐
              │                               Vacant)    │ Occupied │
              │                                           └──────────┘
              │                                                │
              │            admin manual override               │
              └──────────────────── Blocked (Maintenance) ◀────┘
                                     admin manual override
                                     (Blocked → Vacant when
                                      maintenance complete)
```

* `Occupied` can only be entered via an approved resident binding — never set manually.
* `Blocked` is always a manual admin action (e.g., renovation) and can be lifted back to `Vacant` manually.

## 9. Flow 7 — Offline Post Creation → Sync

```
Resident composes a post while offline
      ↓
Flutter app writes to Firestore's local persistence cache
(write appears to succeed immediately in the UI — optimistic)
      ↓
Device reconnects to network
      ↓
Firestore SDK automatically flushes the queued write to the
server — no explicit "retry" action required from the resident
      ↓
Once synced, the post becomes visible to other residents via
their own realtime listeners
      ↓
(If the write ultimately fails — e.g., blocked by a security
rule such as duplicate-account check — the app surfaces an
inline error on that specific post item, not a global alert)
```

## 10. Notes on Realtime Architecture

* All "instant update" behavior (Feed, Chat, Notifications, reaction/comment counts) is powered by **Firestore snapshot listeners** on the client — not polling, and not dependent on the Cloud Function at all.
* There is exactly **one** Cloud Function in the system, triggered `onCreate` of `notifications/{id}` (never on the reaction/comment/message documents themselves). Its only job is: look up the recipient's `fcmToken`, call FCM's send API, and clear the token if FCM reports it stale. See `14_APP_ARCHITECTURE.md` §6 for the full design.
* Using this one Cloud Function does **not** violate the "Firebase Only, no custom backend" principle (see `00_PROJECT_OVERVIEW.md`) — Cloud Functions is a first-party Firebase product, not an external server. The distinction the product principle protects against is a separately-hosted custom backend (e.g., a Node/Express API server), not Firebase's own serverless layer. It does mean the project runs on the **Blaze plan**, whose free tier keeps the realistic monthly cost at $0 for a building this size (`14_APP_ARCHITECTURE.md` §6).

## 11. Future Enhancements

* Presence system (online/last-seen) for chat, using Firebase Realtime Database or Firestore presence pattern
* Typing indicators in chat
* Batched digest notifications (e.g., daily summary) as an alternative to instant-only, once notification volume grows
* Analytics event pipeline (BigQuery export via Firebase Analytics) for the Admin Analytics Dashboard
