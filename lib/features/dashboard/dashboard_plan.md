# Dashboard — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.2
**Arcle module:** `lib/features/dashboard/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

## Overview

Read-only operational overview. Every card/row deep-links into the relevant
feature. Web adds a larger chart area; app shows a scroll of cards. Empty
state on a first-run building (zero apartments) shows a "Set up your
building" CTA into Buildings.

## Screens

- Dashboard (single screen, both surfaces; layout density differs)

## UI Tasks

- [ ] Apartment KPI cards: vacant / pending_approval / occupied / blocked counts
- [ ] Floor vs. occupancy breakdown — table on web, stacked cards on app (e.g. "Floor 1 — 4 apartments, 3 occupied, 1 vacant")
- [ ] Resident count card
- [ ] Pending requests queue widget, tap-through into Residents §7.5.1
- [ ] Engagement summary: total posts/comments/reactions, top-N active residents, poll participation rate
- [ ] Recent activity feed (posts, announcements, recently-decided apartment_requests) ordered by `createdAt desc`
- [ ] Deep-link every card/row into its owning feature (tap a KPI → Apartments, tap pending request → Residents)
- [ ] Empty state: "Set up your building" CTA → Buildings

## Firebase Connection Tasks

- [ ] Realtime listener: `apartments where buildingId == X` (group client-side by `status` and by `floor`)
- [ ] Realtime listener: `apartment_requests where buildingId == X && status == "pending"`
- [ ] Realtime/derived read: `posts` (counts, engagement sums, most-active residents)
- [ ] Realtime/derived read: `announcements` (recent activity feed)
- [ ] Resident count derived from `apartments where status == "occupied"` (equivalently `users` with `apartmentId != null`)
- [ ] Poll participation rate: `votes` count ÷ resident count per active poll
- [ ] No writes — this screen is entirely read-only
