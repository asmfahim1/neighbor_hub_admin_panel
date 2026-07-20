# Moderation — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.6
**Arcle module:** `lib/features/moderation/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Realtime listener on all `posts` for the building
- [ ] Realtime listener on `posts/{postId}/comments` for the open thread
- [ ] Resolve real author via `post_authorship/{postId}.authorUid`, regardless of `isAnonymous`
- [ ] Delete any post / any comment
- [ ] Lock comments: `isLocked → true` (blocks new comments, existing stay visible)
- [ ] Pin a post: `isPinned → true` (moves to top of resident feed)
- [ ] No separate audit-log collection exists yet — actions are only implicitly tracked via `updatedAt` (flag if a formal `moderation_log` is wanted later, per doc §11 item 2)
