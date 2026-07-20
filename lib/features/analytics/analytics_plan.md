# Analytics — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.9
**Arcle module:** `lib/features/analytics/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Deeper, chart-based version of the Dashboard's summary data over a longer
window. Read-only; entirely client-side aggregation over existing
collections (no dedicated `analytics` collection by design).

## Screens

- Web: full charts + export-ready tables
- App: summary + drill-down

## UI Tasks

- [ ] Occupancy trend chart
- [ ] Post/comment/reaction volume-over-time chart
- [ ] Category breakdown (`discussion`/`recommendation`/`help`/`service`/anonymous)
- [ ] Most-active-residents leaderboard
- [ ] Poll participation history view
- [ ] Web: export-ready table views alongside charts
- [ ] App: summary cards with drill-down navigation
- [ ] Replace the placeholder `analytics_screen.dart` (compiles against the real `AnalyticsBloc`/`AnalyticsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Read `apartments` (occupancy) — `WatchAnalyticsApartmentsUseCase` → `AnalyticsEntity.compute` (`apartmentStatusCounts`, `residentCount`, `occupancyRate`)
- [x] Read `posts` (volume, category breakdown, active-residents leaderboard) — `WatchAnalyticsPostsUseCase` (top 500 by `createdAt desc`, matches the `posts` composite index in `05_FIRESTORE_DATABASE.md` §5); category breakdown buckets by `"anonymous"` whenever `isAnonymous == true` (regardless of `category`), else by `category`/`"uncategorized"`
- [x] Read `polls` (participation) — `WatchAnalyticsPollsUseCase` → `PollParticipationEntity` (`totalVotes` ÷ `residentCount`, using `PollEntity.totalVotes` already denormalized on the poll doc — no per-poll `votes` subcollection reads)
- [x] All computation is client-side, read-only — no writes, no `analytics` collection: confirmed, `AnalyticsRepository`/`AnalyticsRemoteSource` expose only `watch*` methods
- [x] Flag as a scale concern if resident count grows materially beyond ~100 (doc §11 item 3) — see note below

### Architecture notes

- `AnalyticsEntity` is a feature-local **aggregate** (not a `core/models` entity), mirroring `DashboardEntity`'s shape exactly: a pure, synchronous `AnalyticsEntity.compute(...)` static factory, recomputed by the bloc on every emission from any of the three listeners (apartments/posts/polls) — same `rxdart`-free `combineLatest` stand-in as Dashboard (§7.9).
- **No stored time-series exists in the schema** (`05_FIRESTORE_DATABASE.md` has no analytics/snapshot collection), so "occupancy trend" and "volume over time" are necessarily computed from the *current* fetch window only, not true historical data: `postsByDay` buckets the (up to 500) fetched posts by their own `createdAt` day — it is a same-window breakdown, not a real trend line. Documenting this explicitly so it isn't mistaken for stored history later.
- Category breakdown treats `"anonymous"` as its own bucket (from `isAnonymous`), independent of `category` — a post can carry both, so these are two different dimensions rather than one 5-way partition. See the doc comment on `AnalyticsEntity.categoryBreakdown` for the exact bucketing rule.
- Poll participation reuses `PollEntity.totalVotes` (denormalized `voteCount` sum across `options`, already on the poll doc) rather than reading each poll's `votes` subcollection — cheaper and consistent with how Polls itself will display counts.
- Scale flag (§11 item 3): the 500-post client-side fetch is the practical ceiling of this "no `analytics` collection" approach — fine at ~100 residents/one building, but would need revisiting (e.g. a real aggregation pipeline) if resident/post count grows materially.
- Same "read-only, multi-collection aggregation" pattern as Dashboard — the two features intentionally each read `apartments`/`posts` independently via their own remote source, rather than sharing one (standard feature isolation, not a violation).
