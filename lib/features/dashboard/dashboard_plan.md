# Dashboard — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §7.2
**Arcle module:** `lib/features/dashboard/` (data/domain/presentation, BLoC)
**Status:** Data/domain/presentation wired to Firebase (poll participation
rate deferred - see note below).
**UI status:** Dashboard/admin-shell UI is implemented for the Dashboard route.
Shared extraction for all other post-login pages remains a follow-up.

## Overview

Read-only operational overview. Every card/row deep-links into the relevant
feature. Web adds a larger chart area; app shows a scroll of cards. Empty
state on a first-run building (zero apartments) shows a "Set up your
building" CTA into Buildings.

## Screens

- Dashboard (single screen, both surfaces; layout density differs)

## Resident App Analytics Metrics

Dashboard should include a small "Resident app analytics" section with:

- User app downloads / installs.
- Realtime active users.

These metrics are not available from the current Firestore schema. Firestore
can display them only after the Resident App or an analytics pipeline writes a
readable source, for example `app_metrics/{buildingId}` with fields such as
`installCount`, `activeUsersNow`, `activeUsersToday`, and `updatedAt`.
Firebase Analytics can collect installs/active users, but the admin client
cannot query Firebase Analytics directly from Firestore without an export,
backend, or scheduled sync. Until that source exists, the dashboard UI should
show the analytics cards with a clear "Data source pending" state rather than
fake numbers.

## Admin Shell & Navigation UI Plan

This dashboard pass should introduce the authenticated admin shell used by
all post-login screens, not just replace the dashboard body. After successful
signup/sign-in, the admin lands on Dashboard inside this shell.

### Responsive navigation

- **Web / desktop:** persistent left sidebar.
- **Mobile / app:** bottom navigation with five primary destinations:
  `Dashboard`, `Requests`, `Announcements`, `Notifications`, `Menu`.
- **Tablet / narrow desktop:** keep the same information architecture; choose
  the sidebar only when the web breakpoint is active, otherwise use the mobile
  bottom navigation pattern.

### Web sidebar items

Use the same route set already defined in `AppRoutes`, grouped for scanning:

- Primary: `Dashboard`, `Requests`, `Apartments`, `Residents`
- Communication: `Announcements`, `Chat`, `Notifications`
- Management: `Building`, `Moderation`, `Polls`, `Analytics`
- Account: `Profile`, `Settings`, `Sign out`

`Requests` maps to the Residents module's pending request queue
(`Residents` section 7.5.1), while `Residents` maps to the resident directory.
If both are implemented in the same route at first, the route should accept a
tab/initial-section argument later rather than creating duplicate business
logic.

### Mobile bottom navigation

Bottom navigation should stay compact and action-focused:

- `Dashboard` -> `AppRoutes.dashboard`
- `Requests` -> Residents pending request queue
- `Announcements` -> `AppRoutes.announcements`
- `Notifications` -> `AppRoutes.notifications`
- `Menu` -> opens the mobile admin menu; it is not a separate destination

The selected tab should reflect the active primary screen. When the admin
opens a secondary screen from Menu, the bottom bar can keep `Menu` selected or
leave no selected tab, but it must not mislabel the screen as Dashboard.

### Mobile Menu drawer/sheet

Pressing `Menu` opens a navigation drawer or full-height modal sheet. The top
area shows the signed-in admin identity:

- Person avatar/photo
- Display name
- Email
- Role label (`Admin`)

Below that, show the same secondary options available from the web sidebar:

- `Building`
- `Apartments`
- `Residents`
- `Moderation`
- `Polls`
- `Analytics`
- `Chat`
- `Profile`
- `Settings`
- `Sign out`

The menu should close before navigating, so back behavior remains predictable.

### Settings in shell/menu

Settings can reuse the existing `AppSettingsCubit` and `SettingsBody`
behavior:

- Theme: light / dark
- Language: English (`en`) / Bangla (`bn`)

On web this can be reached from the sidebar `Settings` item. On mobile it is
reached from the Menu list. A later polish pass can decide whether Settings is
a full screen, drawer section, or modal sheet; the first implementation should
prefer a normal screen to keep routing simple.

### Session and lifecycle requirements

- The shell must be shown only after `AuthBloc` resolves an authenticated
  admin session.
- Feature screens must start their realtime listeners using
  `CurrentSession.requireBuildingId()` / `CurrentSession.requireUid()` as
  appropriate. Today the placeholder screens do not dispatch their
  `*WatchStarted` events, so this dashboard pass must wire
  `DashboardWatchStarted(buildingId)` at minimum.
- If a restored route opens directly into a post-login screen before the
  session is ready, route through the splash/auth gate instead of letting
  `CurrentSession` throw.
- Sign out should dispatch the existing auth/profile sign-out path, clear the
  session, and navigate back to `AppRoutes.auth` or `AppRoutes.splash`.

## UI Tasks

- [x] Build authenticated admin shell on the Dashboard route: responsive web sidebar +
      mobile bottom navigation.
- [x] Keep `dashboard_screen.dart` as a thin route/session wrapper and place
      dashboard UI components in `presentation/widgets/`.
- [ ] Extract the admin shell into a reusable wrapper for every post-login
      feature screen.
- [x] Mobile bottom navigation: `Dashboard`, `Requests`, `Announcements`,
      `Notifications`, `Menu`.
- [x] Mobile `Menu` drawer/sheet with avatar, name, email, role, secondary
      navigation items, settings entry, and sign-out.
- [x] Web sidebar with Dashboard, Requests, Building, Apartments, Residents,
      Moderation, Announcements, Polls, Analytics, Chat, Notifications,
      Profile, Settings, Sign out.
- [x] Wire post-login Dashboard to start `DashboardWatchStarted` using
      `CurrentSession.requireBuildingId()`.
- [x] Resident app analytics cards: app downloads/installs and realtime active
      users. Initial UI shows "Data source pending" until a Firestore or
      Firebase Analytics sync source exists.
- [x] Apartment KPI cards: vacant / pending_approval / occupied / blocked counts
- [x] Floor vs. occupancy breakdown - progress rows on web and app
- [x] Resident count card
- [x] Pending requests queue widget, tap-through into Residents pending queue
- [x] Engagement summary: total posts/comments/reactions and top-N active residents
- [ ] Poll participation rate in engagement summary
- [x] Recent activity feed (posts and announcements) ordered by `createdAt desc`
- [x] Deep-link every card/row into its owning feature
- [x] Empty state: "Set up your building" CTA to Buildings
- [x] Replace the placeholder `dashboard_screen.dart` with real UI.

## Firebase Connection Tasks

- [x] Realtime listener: `apartments where buildingId == X` (grouped client-side by `status` and by `floor`) — `WatchDashboardApartmentsUseCase` → `DashboardEntity.compute`
- [x] Realtime listener: `apartment_requests where buildingId == X && status == "pending"` — `WatchDashboardPendingRequestsUseCase`
- [x] Realtime/derived read: `posts` (counts, engagement sums, most-active residents) — `WatchDashboardRecentPostsUseCase` (top 50 by `createdAt desc`, matches the `posts` composite index in `05_FIRESTORE_DATABASE.md` §5)
- [x] Realtime/derived read: `announcements` (recent activity feed) — `WatchDashboardRecentAnnouncementsUseCase`
- [x] Resident count derived from `apartments where status == "occupied"` — `DashboardEntity.compute` (`apartmentStatusCounts[occupied]`)
- [ ] Poll participation rate: `votes` count ÷ resident count per active poll — **deferred**, not implemented in this pass (see note below)
- [x] No writes — this screen is entirely read-only, confirmed: `DashboardRepository`/`DashboardRemoteSource` expose only `watch*` methods

### Architecture notes

- `DashboardEntity` is a feature-local **aggregate** (not a `core/models` entity) — `DashboardEntity.compute(...)` is a pure, synchronous, unit-testable static factory that recomputes the full snapshot from the four raw lists. The bloc holds the latest emission of each of the four listeners and calls `compute` again on every update — this is the project's stand-in for `rxdart`'s `combineLatest` (not added as a dependency for this scale, per §7.9).
- Recent activity feed intentionally excludes recently-decided `apartment_requests`: showing them would need a `whereIn(status, [approved, rejected]) + orderBy(decidedAt)` query, and no composite index for that shape is declared in `05_FIRESTORE_DATABASE.md` §5. Shipping it would risk a `failed-precondition` runtime error. Flagging as a follow-up (add the index + query) rather than guessing.
- Poll participation rate is deferred for the same reason it's cross-feature: it needs `polls` + `polls/{id}/votes` counts, which the Polls feature owns. Once Polls' remote source exists, Dashboard should add a fifth `watchActivePolls` stream here rather than duplicating Polls' Firestore access.
- Serves as the "read-only, multi-collection aggregation" exemplar (Buildings covers single-doc + bulk batch; Apartments covers collection CRUD + realtime list).
