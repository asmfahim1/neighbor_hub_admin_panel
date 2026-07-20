# Residents — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.5 (§7.5.1–§7.5.4)
**Arcle module:** `lib/features/residents/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase (two sub-items
deferred pending required composite/collection-group indexes — see below).
UI is still the arcle placeholder — real UI/UX is a separate pass once the
design is ready.

## Overview

Four sub-flows in one module: pending-request approval queue, resident
directory, resident detail & removal, and the single-admin transfer/leave
flow. This is the core admin-value module per the doc's delivery order (§10).

## Screens

- Pending Request Queue (§7.5.1)
- Resident Directory (§7.5.2)
- Resident Detail & Removal (§7.5.3)
- Transfer Admin Role picker (§7.5.4, entry point lives in Profile §7.12)

## UI Tasks

- [ ] Pending Request Queue list: requester `displayName`, `apartmentId`, `familyNote`, `createdAt`
- [ ] Approve / Reject actions with confirmation, human-readable failure copy on rule rejection (e.g. "This resident already has an active apartment")
- [ ] Resident Directory: list + search (`displayName`, resolved apartment number, `photoUrl`), including the admin's own public profile
- [ ] Resident Detail: profile fields, bound apartment, join date, lightweight post/comment/reaction activity summary
- [ ] Remove-resident action with a confirmation dialog that explains the consequence (loses feed/chat access; post/comment history remains for audit)
- [ ] Filtered queue view for residents with `accountStatus == "deletion_requested"`
- [ ] Transfer Admin Role picker: only occupied residents selectable; explicit guardrail messaging when there are zero eligible residents (manual Console fallback, not self-service)
- [ ] Replace the placeholder `residents_screen.dart` (compiles against the real `ResidentsBloc`/`ResidentsState`, no design applied) with real UI once available

## Firebase Connection Tasks

- [x] Realtime listener: `apartment_requests where buildingId == X && status == "pending"` — `WatchPendingRequestsUseCase` → `ResidentsFirestoreSource.watchPendingRequests` (each requester's `displayName` best-effort resolved from `users/{uid}`, join failures never break the list)
- [x] **Approve** — one `WriteBatch`: `apartment_requests/{uid}.status → "approved"` + `decidedBy`/`decidedAt`; `apartments/{apartmentId}.status → "occupied"` + `primaryResidentUid → uid`; `users/{uid}.buildingId/apartmentId` — `ApproveRequestUseCase` → `ResidentsFirestoreSource.approveRequest` (`adminUid` supplied by the caller, not read from session state inside the repository)
- [x] **Reject** — `apartment_requests/{uid}.status → "rejected"` + `decidedBy`/`decidedAt` (apartment untouched) — `RejectRequestUseCase`
- [x] Create a `notifications` doc for the requester on approve/reject — `ResidentsFirestoreSource._notifyDecision`, best-effort/non-fatal (mirrors `AuthFirestoreSource.registerFcmTokenSilently`)
- [ ] Admin-side live listener on `apartment_requests` (`status == "pending"`) → local notification via `flutter_local_notifications` on newly-added docs while app is alive — **not implemented in this pass**; the realtime `watchPendingRequests` stream exists and is the right hook, but wiring `docChanges()`-based new-doc detection into `NotificationService.show(...)` is presentation/app-lifecycle glue better done alongside the Notifications feature's equivalent wiring (see `notifications_plan.md`) — flagged as a follow-up, not guessed at here
- [x] Resident Directory: read `users where buildingId == X` — `WatchResidentDirectoryUseCase` → `ResidentsFirestoreSource.watchResidentDirectory`. Resolving the admin's own profile via `buildings/{buildingId}.adminUid` is a resident-app-side concern per §7.10.1 — nothing additional needed here
- [x] **Remove resident** — one `WriteBatch`: `users/{uid}.apartmentId → null`; `apartments/{apartmentId}.status → "vacant"` + `primaryResidentUid → null`; `users/{uid}/private/account.accountStatus → "removed"` — `RemoveResidentUseCase` → `ResidentsFirestoreSource.removeResident`
- [x] **Transfer Admin Role** — one `WriteBatch`: successor `users/{uid}/private/account.role → "admin"`; current admin `private/account.role → "resident"`; `buildings/{buildingId}.adminUid → successorUid` — `TransferAdminRoleUseCase` → `ResidentsFirestoreSource.transferAdminRole`
- [x] Resident Detail activity summary (post/comment/reaction counts) — `GetResidentActivitySummaryUseCase` → `ResidentsRepositoryImpl.getResidentActivitySummary`, computed client-side by reading all of the building's `posts` (covered by the declared `(buildingId, createdAt desc)` index) and filtering by `authorUid` in memory — deliberately does **not** add an `authorUid` equality filter to the Firestore query itself, since `(buildingId, authorUid)` isn't a declared composite index in `05_FIRESTORE_DATABASE.md` §5 and would risk a `failed-precondition` runtime error
- [ ] Filtered queue of residents with `accountStatus == "deletion_requested"` — **not implemented**: this needs a Firestore collection-group query across every user's `private/account` subdocument, which needs a collection-group index not declared anywhere in the schema docs. Do not add this with an undeclared ad-hoc query — flagged as a follow-up once that index is added

### Architecture notes

- Uses `UserEntity`/`ApartmentRequestEntity`/`ApartmentEntity` directly from `core/models/` (1:1 document mirrors) — `domain/entity` and `data/model` are re-export shims, same pattern as Buildings/Apartments. `ResidentActivitySummaryEntity` is the one feature-local aggregate (not a document mirror), alongside `domain/entity/residents_entity.dart`.
- `data/source/residents_remote_source.dart` (`ResidentsRemoteSource` / `ResidentsFirestoreSource`) is the only file a future backend swap touches.
- Approve/Reject/Remove/Transfer all take the relevant uid(s) (`adminUid`, `currentAdminUid`, etc.) as explicit parameters rather than reading `CurrentSession` inside the repository/remote-source — keeps the data layer framework-agnostic about "who is calling"; the bloc is expected to supply these from `CurrentSession.requireUid()` (`lib/core/firebase/current_session.dart`).
- The bloc holds two independent stream subscriptions (pending requests + resident directory), mirroring `dashboard_bloc.dart`'s multi-subscription pattern; resident detail/removal/transfer are one-shot `Future`-based handlers on the same bloc.
