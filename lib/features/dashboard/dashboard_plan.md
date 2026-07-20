# Dashboard — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.2
**Arcle module:** `lib/features/dashboard/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase (poll participation
rate deferred — see note below). UI is still the arcle placeholder — real
UI/UX is a separate pass once the design is ready.

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
- [ ] Replace the placeholder `dashboard_screen.dart` (compiles against the real `DashboardBloc`/`DashboardState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener: `apartments where buildingId == X` (grouped client-side by `status` and by `floor`) — `WatchDashboardApartmentsUseCase` → `DashboardEntity.compute`
- [x] Realtime listener: `apartment_requests where buildingId == X && status == "pending"` — `WatchDashboardPendingRequestsUseCase`
- [x] Realtime/derived read: `posts` (counts, engagement sums, most-active residents) — `WatchDashboardRecentPostsUseCase` (top 50 by `createdAt desc`, matches the `posts` composite index in `05_FIRESTORE_DATABASE.md` §5)
- [x] Realtime/derived read: `announcements` (recent activity feed) — `WatchDashboardRecentAnnouncementsUseCase`
- [x] Resident count derived from `apartments where status == "occupied"` — `DashboardEntity.compute` (`apartmentStatusCounts[occupied]`)
- [ ] Poll participation rate: `votes` count ÷ resident count per active poll — **deferred**, not implemented in this pass (see note below)
- [x] No writes — this screen is entirely read-only, confirmed: `DashboardRepository`/`DashboardRemoteSource` expose only `watch*` methods

### Architecture notes

- `DashboardEntity` is a feature-local **aggregate** (not a `core/models` entity) — `DashboardEntity.compute(...)` is a pure, synchronous, unit-testable static factory that recomputes the full snapshot from the four raw lists. The bloc holds the latest emission of each of the four listeners and calls `compute` again on every update — this is the project's stand-in for `rxdart`'s `combineLatest` (not added as a dependency for this scale, per §7.9).
- Recent activity feed intentionally excludes recently-decided `apartment_requests`: showing them would need a `whereIn(status, [approved, rejected]) + orderBy(decidedAt)` query, and no composite index for that shape is declared in `05_FIRESTORE_DATABASE.md` §5. Shipping it would risk a `failed-precondition` runtime error. Flagging as a follow-up (add the index + query) rather than guessing.
- Poll participation rate is deferred for the same reason it's cross-feature: it needs `polls` + `polls/{id}/votes` counts, which the Polls feature owns. Once Polls' remote source exists, Dashboard should add a fifth `watchActivePolls` stream here rather than duplicating Polls' Firestore access.
- Serves as the "read-only, multi-collection aggregation" exemplar (Buildings covers single-doc + bulk batch; Apartments covers collection CRUD + realtime list).
