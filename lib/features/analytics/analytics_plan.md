# Analytics — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.9
**Arcle module:** `lib/features/analytics/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Read `apartments` (occupancy trend)
- [ ] Read `posts` (volume, category breakdown, active-residents leaderboard)
- [ ] Read `polls` (participation history)
- [ ] All computation is client-side, read-only — no writes, no `analytics` collection
- [ ] Flag as a scale concern if resident count grows materially beyond ~100 (doc §11 item 3)
