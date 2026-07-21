# Chat — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.10, §7.10.1
**Arcle module:** `lib/features/chat/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase. UI is still the
arcle placeholder — real UI/UX is a separate pass once the design is ready.

## Overview

Admin has their own 1:1 conversations with residents — same rules as a
resident participant; no special chat-oversight power over conversations the
admin isn't part of. Admin starts a chat from the Resident Directory
(§7.5.2). The resident-side "who is the admin" discovery gap is resolved via
`buildings/{buildingId}.adminUid` (§6.1) — no extra work needed here beyond
keeping that field correct, which the Transfer flow (§7.5.4) already
guarantees.

## Screens

- Chat List
- Conversation

## UI Tasks

- [ ] Chat List screen (conversations the admin participates in)
- [ ] Conversation screen (message thread, send box)
- [ ] "Start chat" entry point from Resident Directory (tap a contact)
- [ ] Participant status -> Online/Offline, Last Seen (time) — **no data-layer work possible yet**: no presence/online-status field exists anywhere in `05_FIRESTORE_DATABASE.md`'s `users` or `conversations` schema; needs a schema/design decision before this can be built
- [ ] Replace the placeholder `chat_screen.dart`/`chat_card.dart` (compiles against the real `ChatBloc`/`ChatState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener: `conversations where participantUids array-contains myUid` — `WatchConversationsUseCase` → `ChatFirestoreSource.watchConversations` (matches the documented `(participantUids array-contains, buildingId)` composite index)
- [x] Realtime listener: `conversations/{id}/messages` — `WatchMessagesUseCase`, started/stopped per `ConversationOpened`/`ConversationClosed` event, chronological order
- [x] Send message write to `conversations/{id}/messages` — `SendMessageUseCase` → `ChatFirestoreSource.sendMessage`, one `WriteBatch` (new message doc + parent conversation's `lastMessage`/`lastMessageAt`)
- [x] Create a `notifications` doc for the recipient on new message (category: `chat`) — best-effort, non-fatal on failure (mirrors `AuthFirestoreSource.registerFcmTokenSilently`'s try/catch shape)
- [x] No special admin-only read/write path — same rules as any participant — confirmed, `ChatRepository`/`ChatRemoteSource` have no admin-only branch
- [x] Bonus: `startOrResumeConversation` (deterministic id via `FirestorePaths.conversationIdFor`, checks existence before writing so a repeat "start chat" tap never clobbers `createdAt`/history) — the entry point from Resident Directory

### Architecture notes

- Uses `ConversationEntity`/`MessageEntity` directly from `core/models/` (1:1 document mirrors) — `domain/entity` and `data/model` are re-export shims, same pattern as Apartments.
- `data/source/chat_remote_source.dart` (`ChatRemoteSource` / `ChatFirestoreSource`) is the only file a future backend swap touches.
- `myUid`/`otherUid`/`buildingId` are passed in as parameters everywhere (from `CurrentSession` at the call site) rather than read inside the repository/remote-source, keeping the data layer framework-agnostic about "who is calling" — same convention as every other delegated feature.
- The bloc holds two independent subscriptions (conversation list + the currently-open conversation's messages), mirroring `dashboard_bloc.dart`'s/`moderation_bloc.dart`'s multi-subscription pattern.

