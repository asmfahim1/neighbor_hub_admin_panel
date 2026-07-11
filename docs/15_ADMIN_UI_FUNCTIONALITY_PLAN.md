# NeighborHub — Admin UI and Functionality Plan

**Version:** 0.1 (Planning Phase)
**Depends on:** `02_ADMIN_SYSTEM.md`, `04_UI_UX_GUIDELINES.md`, `05_FIRESTORE_DATABASE.md`, `06_FIREBASE_SECURITY.md`, `14_APP_ARCHITECTURE.md`

## 1. Purpose

Define the user interface and functionality plan for the NeighborHub admin experience across both the Admin Mobile App and the Admin Web Portal. This document translates the admin system requirements into a concrete screen structure, responsive layout strategy, and Arcle-aligned package/module plan so implementation can start without design ambiguity.

## 2. Product Definition

The admin product is one system with two surfaces:

* **Admin App**: mobile-first operational tool for approvals, moderation, announcements, and quick building management tasks.
* **Admin Web Portal**: desktop-first control center for building setup, bulk apartment operations, analytics review, and data-heavy workflows.

Both surfaces share the same Firebase backend, the same data model, the same security rules, and the same visual language. The difference is density and task emphasis, not feature scope.

## 3. Design Principles

1. **Same system, different density** - the app and portal must feel like one product, not two unrelated dashboards.
2. **Operational first** - the admin experience should optimize for fast decisions, clear queues, and low-friction moderation.
3. **Data dense, not cluttered** - the web portal may use tables, split panes, filters, and inline actions; the mobile app should use cards, bottom sheets, and focused detail screens.
4. **Text-first** - no media upload flows are needed in MVP, so typography, spacing, status chips, and hierarchy carry the UI.
5. **Rules-aware UX** - destructive or cross-building actions must be prevented or confirmed in the UI before Firestore rejects them.
6. **Realtime by default** - approvals, moderation, announcements, and dashboard counts should reflect live Firestore updates.
7. **Accessible and calm** - keep the Material 3 foundation from `04_UI_UX_GUIDELINES.md`, with AA contrast, predictable patterns, and clear empty states.

## 4. Arcle Package Architecture

The admin product should be split using the same Arcle structure described in `14_APP_ARCHITECTURE.md`, but with the admin-specific feature set made explicit.

### 4.1 Shared Package

`packages/neighborhub_core` should hold everything both admin and resident apps must agree on:

* Firestore models and serializers for buildings, apartments, users, requests, posts, comments, notifications, polls, and conversations.
* Shared constants for status values, categories, route names, and validation rules.
* Firebase repository helpers for batch writes and common read patterns.
* Shared theme tokens, text styles, spacing, and component primitives.
* Shared permission helpers and building-scoped query helpers.

### 4.2 Admin App Modules

The Admin App should be scaffolded as an Arcle app with these feature modules:

* `dashboard`
* `buildings`
* `apartments`
* `residents`
* `moderation`
* `announcements`
* `polls`
* `analytics`
* `profile`

Recommended module responsibility split:

| Module | Responsibility |
|---|---|
| `dashboard` | High-level summary cards, pending action queues, alerts, and building health overview |
| `buildings` | Building profile, address, floor/apartment configuration, and building-level settings |
| `apartments` | Apartment table/card management, status changes, bulk generation, and occupancy state review |
| `residents` | Request approval queue, resident directory, profile review, and removal flows |
| `moderation` | Post and comment moderation, pin/lock/delete actions, anonymous-author inspection |
| `announcements` | Compose, schedule if needed, publish, edit, delete, and audit announcements |
| `polls` | Create polls, close polls, inspect votes, and review participation |
| `analytics` | Trend charts, KPI breakdowns, and export-ready summaries |
| `profile` | Admin account profile, theme settings, and sign-out |

### 4.3 Why `buildings` is a separate feature

The admin system includes building setup and floor configuration as a primary workflow. Keeping that logic in its own feature prevents the building form from leaking into unrelated profile or apartment code, and it gives the web portal a clean entry point for initial setup.

## 5. Navigation and Layout

### 5.1 Admin App

The mobile app should use an adaptive navigation shell:

* **Phone portrait**: bottom navigation for the primary operational areas.
* **Tablet / landscape**: navigation rail or compact drawer if more space is available.

Recommended primary destinations:

* `Dashboard`
* `Residents`
* `Moderation`
* `Announcements`
* `More`

The `More` area can contain `Apartments`, `Polls`, `Analytics`, `Building Settings`, and `Profile` so the mobile shell stays readable while still exposing the full admin scope.

### 5.2 Admin Web Portal

The web portal should use a persistent left sidebar and a top utility bar.

Sidebar items:

* `Dashboard`
* `Buildings`
* `Apartments`
* `Residents`
* `Moderation`
* `Announcements`
* `Polls`
* `Analytics`
* `Profile`

Portal layout pattern:

* **Left sidebar** for global navigation.
* **Top bar** for building switch context, search, filters, and quick actions.
* **Main canvas** for tables, charts, forms, and split views.
* **Detail drawer or side panel** for record inspection and edits without leaving the current list.

### 5.3 Responsive Behavior

* Under tablet width, tables should collapse into stacked cards or responsive rows.
* Desktop should prefer dense tables, inline filters, and bulk actions.
* Mobile should prefer card lists, step-by-step forms, and bottom sheets for confirmations.
* All breakpoints should preserve the same information architecture, only changing density and interaction pattern.

## 6. Screen and Flow Plan

### 6.1 Dashboard

Purpose: give the admin an immediate status readout of the building.

UI elements:

* KPI cards for apartments, vacant, occupied, pending approvals, blocked, residents, posts, comments, and pending requests.
* Action queue cards for approvals, moderation items, and broadcasts.
* Short activity feed for recent admin actions or resident changes.
* Chart widgets on web for occupancy and engagement trends.

Functionality:

* Realtime refresh from Firestore listeners.
* Quick jump actions into approval, apartment, or moderation detail screens.
* Web-only export or deeper chart exploration can live here or in analytics.

### 6.2 Buildings

Purpose: manage the building identity and floor/apartment configuration.

UI elements:

* Building detail card or form.
* Address and floor configuration fields.
* Apartment generation controls on web.
* Validation summary for required fields and reserved counts.

Functionality:

* Create and update building metadata.
* Edit total floors and apartments per floor.
* Trigger bulk apartment generation on the web portal.
* Prevent cross-building edits through the current admin context.

### 6.3 Apartments

Purpose: manage apartment inventory and occupancy state.

UI elements:

* Web: searchable table with inline status, floor, number, description, and occupancy state.
* Mobile: grouped apartment cards with quick edit actions.
* Status chips for `Vacant`, `Pending Approval`, `Occupied`, and `Blocked`.

Functionality:

* Create, edit, and delete apartment records.
* Change status with validation.
* Show the current resident binding when occupied.
* Support bulk generation and bulk review on web.

### 6.4 Residents

Purpose: review requests, approve residents, inspect resident records, and remove residents when needed.

UI elements:

* Pending request queue.
* Resident directory list.
* Resident detail panel with apartment, join date, activity summary, and account state.
* Approval and rejection actions with confirmation copy.

Functionality:

* Approve request -> bind user to apartment -> set apartment occupied.
* Reject request -> release apartment back to vacant.
* Remove resident -> revoke access and return apartment to vacant.
* Surface duplicate-account blocks as explanatory states instead of letting the user guess why a request failed.

### 6.5 Moderation

Purpose: keep the building feed safe and usable.

UI elements:

* Moderation queue or content list.
* Post detail view with author context, including anonymous author reveal for admins.
* Comment thread view with delete controls.
* Pin and lock actions.

Functionality:

* Delete any post.
* Delete any comment.
* Pin or lock posts.
* Show the real author behind anonymous posts in admin-only views.
* Keep the resident-facing feed state synced in realtime after moderation actions.

### 6.6 Announcements

Purpose: publish official building communications.

UI elements:

* Announcement composer.
* Draft / published / archived states if needed.
* Announcement list with edit and delete actions.

Functionality:

* Create, edit, and delete announcements.
* Send announcement notifications to all residents in the selected building.
* Keep the content text-only and clearly attributed to building management.

### 6.7 Polls

Purpose: create and manage building polls.

UI elements:

* Poll creation form.
* Poll list with active/closed chips.
* Result visualization for web and simplified result cards for mobile.

Functionality:

* Create single-choice polls.
* Close polls manually or by time.
* Review live and final vote counts.
* Track participation rate for analytics.

### 6.8 Analytics

Purpose: expose building health and engagement metrics.

UI elements:

* Summary KPI cards.
* Occupancy and request charts.
* Engagement charts for posts, comments, reactions, and announcements.
* Most active resident list.

Functionality:

* Read-only reporting surface.
* Web-first deep charts and export support.
* Mobile summary view with drill-down into the most important metrics.

### 6.9 Profile

Purpose: let the admin manage their account and local settings.

UI elements:

* Profile form.
* Theme setting and sign-out actions.
* Optional admin preference controls.

Functionality:

* Update admin profile fields allowed by security rules.
* Switch theme preference if the user overrides system mode.
* Sign out safely without breaking the current building context.

## 7. Functionality Rules by Interaction

### 7.1 Approval Workflow

* Approval must happen as a single atomic batch.
* UI should show the target apartment and the resident request together before commit.
* After approval, the resident should disappear from the pending queue and appear in occupied/resident views immediately.

### 7.2 Destructive Actions

* Delete post, remove resident, block apartment, delete announcement, and delete comment must always use a confirmation dialog or sheet.
* The confirmation copy should explain the consequence, not just repeat the button label.
* Admin actions should prefer undo only where Firestore rules and data flow make it safe.

### 7.3 Realtime Feedback

* Approval queues, counts, feed moderation state, and notifications should all update from live listeners.
* The UI should never require a manual refresh after a successful action.

### 7.4 Error Handling

* Rule failures should map to human-readable messages.
* Duplicate requests, occupied-apartment conflicts, and building mismatch cases should be shown as inline warnings or empty-state explanations.
* Network failure should keep cached content visible when available.

## 8. Shared Components

The admin app and portal should reuse the same component vocabulary from `04_UI_UX_GUIDELINES.md`:

* KPI cards
* Status chips
* Confirmation dialogs
* Data tables
* Form fields
* Bottom sheets / side drawers
* Search bars and filter chips
* Empty states and skeleton loaders

Recommended reusable admin-specific components:

* Building summary card
* Apartment status row
* Resident request row
* Moderation action panel
* Announcement composer
* Poll option editor
* Analytics chart card

## 9. Implementation Notes for Arcle

### 9.1 Repo Structure

Suggested implementation structure:

```text
apps/admin_app/
  lib/
    core/
    features/
      dashboard/
      buildings/
      apartments/
      residents/
      moderation/
      announcements/
      polls/
      analytics/
      profile/
packages/neighborhub_core/
  lib/
    models/
    constants/
    firebase/
    theme/
```

### 9.2 Feature Boundaries

* Presentation layers should own screen widgets, routing, and state coordination.
* Domain layers should own use cases and repository contracts.
* Data layers should wrap Firestore SDK access and batch operations.
* Shared Firestore write helpers should live in `neighborhub_core` so both admin and resident apps use the same atomic write contracts.

### 9.3 Navigation Contract

* App routes should be feature-owned but registered in the app shell.
* Web portal routes should preserve the sidebar selection and deep-linkable detail views.
* Record detail pages should be addressable directly from notifications, search, and dashboard cards.

## 10. Delivery Order

Recommended build order:

1. Scaffold shared package models, constants, and theme tokens.
2. Scaffold admin app shell and routing.
3. Build dashboard and residents first, because approvals are core admin value.
4. Add apartments and building management.
5. Add moderation and announcements.
6. Add polls and analytics.
7. Polish responsive behavior for the web portal.

## 11. Acceptance Criteria

* The admin app and portal present the same data and workflows with different density, not different logic.
* Building setup, apartment management, resident approval, moderation, announcements, and analytics are all reachable from the Arcle feature structure.
* Desktop layouts expose the full admin control surface without feeling cramped.
* Mobile layouts keep the highest-frequency actions within one or two taps.
* All admin actions that change resident state are explainable, confirmed, and realtime-synced.

## 12. Notes

* This plan intentionally replaces the older, less specific admin roadmap language in `docs/neighbor_hub_plan.md` with a module-based structure aligned to `14_APP_ARCHITECTURE.md`.
* The portal should remain a Flutter web app, not a separate technology stack, so shared code stays high and maintenance stays low.
* No image-based UI paths should be introduced for MVP, since the product scope excludes media content entirely.
