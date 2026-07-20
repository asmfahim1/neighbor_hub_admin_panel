# Polls — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.8
**Arcle module:** `lib/features/polls/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

## Overview

Single-choice polls with client-side expiry (no server cron since there are
no Cloud Functions on Spark). Participation rate feeds the Dashboard/Analytics.

## Screens

- Poll list (active/closed chips)
- Poll Creator
- Results view

## UI Tasks

- [ ] Poll list with active/closed status chips
- [ ] Poll Creator: question + single-choice options
- [ ] Results view: live results (while active) and final results (after close)
- [ ] Manual "close poll" action with confirmation

## Firebase Connection Tasks

- [ ] Realtime listener on `polls` for the building
- [ ] Realtime listener on `polls/{id}/votes` for participation counting
- [ ] Create poll doc: `question`, `options[{id, text, voteCount}]`, `status`, `closesAt`
- [ ] Manual close: write `status` on the poll doc
- [ ] Client-side check of `closesAt` at render time (no server-side expiry)
- [ ] Poll participation rate computation feeds Dashboard (§7.2) and Analytics (§7.9)
