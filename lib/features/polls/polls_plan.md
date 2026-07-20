# Polls — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.8
**Arcle module:** `lib/features/polls/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

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
- [ ] Replace the placeholder `polls_screen.dart` (compiles against the real `PollsBloc`/`PollsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener on `polls` for the building — `WatchPollsUseCase` → `PollsFirestoreSource.watchPolls` (ordered `createdAt desc`)
- [x] Realtime listener on `polls/{id}/votes` for participation counting — `WatchPollVotesUseCase`, started/stopped per `PollVotesWatchStarted`/`PollVotesWatchStopped` event (independent of the main poll-list stream, not folded into it)
- [x] Create poll doc: `question`, `options[{id, text, voteCount}]`, `status`, `closesAt` — `CreatePollUseCase` → `PollsRepositoryImpl.createPoll` (generates sequential option IDs `opt_1`, `opt_2`, ... client-side; rejects fewer than two options with a `ValidationFailure`; `createdBy` supplied by the bloc via `CurrentSession.requireUid()`, not read inside the repository/remote-source)
- [x] Manual close: write `status` on the poll doc — `ClosePollUseCase` (the only status-write path this feature performs; no automatic/server-side close)
- [x] Client-side check of `closesAt` at render time (no server-side expiry) — already on the shared `PollEntity.isExpired` getter (`core/models/poll_entity.dart`), reused as-is rather than recomputed here
- [ ] Poll participation rate computation feeds Dashboard (§7.2) and Analytics (§7.9) — **not implemented in this pass**: Dashboard's own plan already flags this as deferred/cross-feature (see `dashboard_plan.md`); once needed, the consumer should call `WatchPollVotesUseCase`/`PollEntity.totalVotes` from here rather than duplicating poll/vote Firestore access

### Architecture notes

- Uses `PollEntity`/`PollOptionEntity`/`PollVoteEntity` directly from `core/models/` (1:1 document mirrors) — `domain/entity` and `data/model` are re-export shims, same pattern as Apartments/Buildings.
- `data/source/polls_remote_source.dart` (`PollsRemoteSource` / `PollsFirestoreSource`) is the only file a future backend swap touches.
- No `castVote` method exists anywhere in this feature — voting is resident-side and out of scope for the Admin App; this feature only ever reads `votes` (for participation) and never writes to that subcollection.
- The bloc holds two independent subscriptions (poll list + the currently-opened poll's votes), mirroring `dashboard_bloc.dart`'s/`moderation_bloc.dart`'s multi-subscription pattern.
