# 02_ADMIN_SYSTEM.md

# NeighborHub — Admin System

**Version:** 0.1 (Planning Phase)
**Applies to:** Admin Mobile/Web App + Admin Web Portal

## 1. Purpose

Define everything a Building Admin can do inside NeighborHub — across both the Admin App and the Admin Web Portal — so that building operations, resident approval, and community moderation can run without a support team.

This document is self-contained. A developer implementing any admin feature should not need to read other docs to understand scope, rules, or workflow.

## 2. Scope

### Included in Admin System (MVP)

* Building management
* Apartment management (with status lifecycle)
* Resident approval & management
* Community moderation (posts, comments)
* Announcements & notices
* Polls (create/close/view results)
* Notification broadcast
* Analytics dashboard
* Admin profile & settings

### Not Included (MVP)

* Multi-building Super Admin console (future)
* Billing / maintenance fee collection (future)
* Visitor management (future)
* Image/media moderation (no images in MVP)

## 3. Roles

| Role | Description |
|---|---|
| **Super Admin** (future) | Platform-level access across all buildings. Not in MVP. |
| **Building Admin** | Full control of a single building: apartments, residents, feed, chat oversight, announcements, analytics. This document assumes Building Admin unless noted. |

## 4. Working Space: App vs Web Portal

Admins get two entry points into the same Firebase backend:

| Capability | Admin App (Mobile) | Admin Web Portal |
|---|---|---|
| Approve/reject resident requests | ✔ | ✔ |
| Push announcements | ✔ | ✔ |
| Moderate posts/comments | ✔ | ✔ |
| Building & apartment CRUD | Limited (view + quick edit) | ✔ Full (bulk creation, floor/apartment generation) |
| Analytics dashboard | Summary cards | ✔ Full charts & exports |
| Resident directory management | ✔ | ✔ |
| Poll creation | ✔ | ✔ |

**Rule:** The Web Portal is the primary console for heavy setup work (creating a building, bulk-generating apartments). The Admin App is for day-to-day operations (approvals, moderation, announcements) while mobile.

## 5. Functional Requirements

### 5.1 Building Management

* Create / update / delete building
* Configure: name, address, total floors, apartments per floor
* No building image upload in MVP (text-only identity, per no-media principle)

### 5.2 Apartment Management

* Create / update / delete apartment
* Fields: apartment number/name, floor, optional description
* **Apartment Status** (required field, one of):
  * `Vacant` — no resident assigned, open for requests
  * `Pending Approval` — a resident has applied, awaiting admin decision
  * `Occupied` — has one approved Primary Resident Account
  * `Blocked (Maintenance)` — admin-disabled, not visible for resident requests
* Admin can manually override status (e.g., force `Blocked` for renovation) except that an apartment cannot be set to `Occupied` without an approved resident record — occupancy is a system-derived state, not a free toggle.

### 5.3 Resident Management (Approval Workflow)

* View incoming apartment requests (status: `Pending Approval`)
* Approve → creates the resident's **Primary Resident Account** binding (1 account per apartment) and flips apartment status to `Occupied`
* Reject → apartment returns to `Vacant`, requester notified
* Remove resident (e.g., moved out) → apartment returns to `Vacant`, resident's building access revoked, chat/feed history retained for audit but resident can no longer post
* **Duplicate account enforcement:** If a user already holds a Primary Resident Account in the building (or system) and attempts a second apartment request, the request is blocked at write-time by Firestore rules and the client shows a warning snackbar ("You already have a resident account for this building"). Admin dashboard also surfaces this as a rejected-automatically log entry, not a manual queue item.
* View resident profile (name, apartment, join date, activity summary)

### 5.4 Community Moderation

* Delete any post (inappropriate, spam, policy violation)
* Delete any comment
* Lock comments on a specific post (stops new comments, existing ones remain visible)
* Pin a post to the top of the feed (e.g., important discussion)
* **Anonymous post moderation:** Anonymous posts always store the real `authorId` internally. The admin moderation view (not the resident feed) reveals the real author for accountability. Residents never see this.
* Moderation actions are logged (who, what, when) for internal audit — not shown to residents.

### 5.5 Announcements & Notices

* Create / edit / delete announcement (building-wide broadcast)
* Announcements are distinct from resident posts — always attributed to "Building Management," never anonymous
* Triggers a categorized `Announcement` notification to every resident in the building

### 5.6 Polls

* Create poll (question + options, single-choice for MVP)
* Close poll manually or by expiry date
* View live results and final results
* Poll activity triggers `Poll` category notifications

### 5.7 Notification Broadcast

* Admin can send a manual announcement-notification independent of a post (e.g., "Water will be shut off tomorrow 9–11 AM")
* Uses the same `Announcement` notification category residents already filter by

### 5.8 Analytics Dashboard

Minimum metrics for MVP:

* Total apartments / Vacant / Occupied / Pending Approval / Blocked
* Total residents
* Pending resident requests (actionable queue)
* Total posts, total reactions, total comments (building-scoped)
* Most active residents (by post/comment/reaction count)
* Most viewed/reacted announcements
* Poll participation rate

### 5.9 Admin Profile & Settings

* Update own profile info
* Manage building-level settings (name, address, floor config)

## 6. Non-Functional Requirements

* All admin writes must be scoped to the building the admin manages (enforced by Firestore Security Rules, not just client logic)
* Every destructive action (delete post, remove resident, block apartment) should require a client-side confirmation step
* Admin actions that affect residents (approval, rejection, removal, moderation) must generate a corresponding resident-facing notification
* Web Portal must remain usable on a standard laptop screen without requiring desktop-app installation (Firebase Hosting + responsive web)

## 7. Admin Workflows

**Approve a Resident**
`Pending request appears` → `Admin reviews applicant info` → `Approve` → `Apartment status: Occupied` → `Resident account activated` → `Resident receives notification` → `Resident sees Dashboard`

**Moderate a Post**
`Post reported or flagged` → `Admin opens moderation view` → `Admin sees real author (even if anonymous)` → `Admin deletes/locks/pins` → `Feed updates in real time for all residents`

**Change Apartment Status**
`Admin selects apartment` → `Chooses new status` → `System validates` (e.g., cannot set Occupied without an approved resident) → `Status updated` → `Reflected in Vacant/Occupied counts on dashboard`

## 8. Permissions Matrix

| Action | Resident | Building Admin | Super Admin (future) |
|---|---|---|---|
| Read building feed | ✔ (own building only) | ✔ | ✔ (all) |
| Create post | ✔ | ✔ | ✔ |
| Edit/delete own post | ✔ | ✔ | ✔ |
| Delete any post | ✘ | ✔ | ✔ |
| Lock/pin post | ✘ | ✔ | ✔ |
| Approve resident | ✘ | ✔ | ✔ |
| Create/edit building | ✘ | ✘ (own building fields only) | ✔ |
| View real identity behind anonymous post | ✘ | ✔ | ✔ |
| Broadcast announcement | ✘ | ✔ | ✔ |
| View analytics | ✘ | ✔ (own building) | ✔ (all buildings) |

## 9. User Stories

* As a Building Admin, I want to approve or reject apartment requests so only verified residents join.
* As a Building Admin, I want to delete inappropriate posts so the community stays respectful.
* As a Building Admin, I want to see who's really behind an anonymous post so I can moderate fairly.
* As a Building Admin, I want a dashboard summary so I understand building health at a glance.
* As a Building Admin, I want to broadcast an announcement so all residents are informed instantly.

## 10. Acceptance Criteria

* Admin cannot approve a request for an apartment that already has an active Primary Resident Account.
* Deleting a post removes it from all residents' feeds in real time (via Firestore listener), not on next refresh.
* Apartment status always reflects actual resident-binding state; it cannot desync (e.g., "Occupied" with no resident).
* Anonymous authorship is never exposed to residents, only to Admin/Super Admin views.

## 11. Notes

* No image/media moderation queue exists because the product excludes image posts by design (see `00_PROJECT_OVERVIEW.md`).
* Admin actions should always be traceable internally, even though the resident-facing UI stays simple.

## 12. Future Enhancements

* Super Admin console for managing multiple buildings/admins
* Report queue (residents flag posts → admin review queue instead of manual scanning)
* Maintenance fee & billing dashboard
* Visitor management module
* Bulk resident import (CSV) via Web Portal
