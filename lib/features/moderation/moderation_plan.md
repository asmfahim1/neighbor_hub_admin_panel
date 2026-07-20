# Moderation — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.6
**Arcle module:** `lib/features/moderation/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Admin browses the full building feed to moderate — there is no resident-facing
"report" queue in MVP. Real-author reveal is admin-only and must never be
shown to residents.

## Screens

- Feed Moderation list (all posts in the building, admin view)
- Post Detail (with real-author reveal)
- Comment thread (with delete)

## UI Tasks

- [ ] Feed Moderation list showing all posts (including `isPinned`/`isLocked` state)
- [ ] Post Detail screen with real-author reveal, clearly marked admin-only
- [ ] Comment thread view with per-comment delete
- [ ] Pin/Lock toggle controls on a post
- [ ] Confirm dialog for delete post / delete comment (explain consequence)
- [ ] Replace the placeholder `moderation_screen.dart` (compiles against the real `ModerationBloc`/`ModerationState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener on all `posts` for the building — `WatchModerationFeedUseCase` → `ModerationFirestoreSource.watchFeed` (ordered `createdAt desc`, matches the documented `(buildingId, createdAt desc)` composite index)
- [x] Realtime listener on `posts/{postId}/comments` for the open thread — `WatchPostCommentsUseCase`, started/stopped per `PostThreadOpened`/`PostThreadClosed` event (chronological order)
- [x] Resolve real author via `post_authorship/{postId}.authorUid`, regardless of `isAnonymous` — `ResolveRealAuthorUseCase` → `ModerationRepositoryImpl.resolveRealAuthor` (one-shot fetch, admin-only, never bulk-loaded with the feed)
- [x] Delete any post / any comment — `DeletePostUseCase` / `DeleteCommentUseCase`
- [x] Lock comments: `isLocked → true` (blocks new comments, existing stay visible) — `SetPostLockedUseCase` (enforcement of "blocks new comments" is a Firestore-rules concern, not client logic)
- [x] Pin a post: `isPinned → true` (moves to top of resident feed) — `SetPostPinnedUseCase`
- [x] No separate audit-log collection exists yet — actions are only implicitly tracked via `updatedAt` (flag if a formal `moderation_log` is wanted later, per doc §11 item 2) — confirmed no `moderation_log` collection was invented

### Architecture notes

- Uses `PostEntity`/`PostAuthorshipEntity`/`CommentEntity` directly from `core/models/` (1:1 document mirrors) — `domain/entity` and `data/model` are re-export shims, same pattern as Apartments.
- `data/source/moderation_remote_source.dart` (`ModerationRemoteSource` / `ModerationFirestoreSource`) is the only file a future backend swap touches.
- The bloc holds two independent subscriptions (feed + the currently-open post's comment thread) and cancels/restarts the comments subscription whenever a different post's thread is opened — mirrors the multi-subscription pattern in `dashboard_bloc.dart`.
