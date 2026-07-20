# Chat — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.10, §7.10.1
**Arcle module:** `lib/features/chat/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Realtime listener: `conversations where participantUids array-contains myUid`
- [ ] Realtime listener: `conversations/{id}/messages`
- [ ] Send message write to `conversations/{id}/messages`
- [ ] Create a `notifications` doc for the recipient on new message (category: `chat`)
- [ ] No special admin-only read/write path — same rules as any participant
