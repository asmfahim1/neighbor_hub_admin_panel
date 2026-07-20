# Residents — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.5 (§7.5.1–§7.5.4)
**Arcle module:** `lib/features/residents/` (data/domain/presentation, BLoC)
**Status:** Scaffolded only — no business logic implemented yet.

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

## Firebase Connection Tasks

- [ ] Realtime listener: `apartment_requests where buildingId == X && status == "pending"`
- [ ] **Approve** — one `WriteBatch`: `apartment_requests/{uid}.status → "approved"` + `decidedBy`/`decidedAt`; `apartments/{apartmentId}.status → "occupied"` + `primaryResidentUid → uid`; `users/{uid}.buildingId/apartmentId` (first-time only, via `isAdminApprovalUpdate` rule)
- [ ] **Reject** — `apartment_requests/{uid}.status → "rejected"` + `decidedBy`/`decidedAt` (apartment untouched)
- [ ] Create a `notifications` doc for the requester on approve/reject
- [ ] Admin-side live listener on `apartment_requests` (`status == "pending"`) → local notification via `flutter_local_notifications` on newly-added docs while app is alive
- [ ] Resident Directory: read `users where buildingId == X`; resolve admin's own profile via `buildings/{buildingId}.adminUid`
- [ ] **Remove resident** — one `WriteBatch`: `users/{uid}.apartmentId → null` (`isAdminRemovalUpdate`); `apartments/{apartmentId}.status → "vacant"` + `primaryResidentUid → null`; `users/{uid}/private/account.accountStatus → "removed"` (`isAdminPrivateUpdate`)
- [ ] **Transfer Admin Role** — one `WriteBatch`: successor `users/{uid}/private/account.role → "admin"`; current admin `private/account.role → "resident"` (self-demotion carve-out); `buildings/{buildingId}.adminUid → successorUid`
