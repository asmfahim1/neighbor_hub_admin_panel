# 16_FEATURE_PLAN_HISTORY_TEMPLATE.md

# Feature `_plan.md` / `_history.md` — Standard Structure

**Status:** Binding convention for every feature going forward, starting with
`auth` (2026-07-21). Applied retroactively to a feature's plan file the next
time that feature is touched.

Every `lib/features/<name>/<name>_plan.md` follows this section order. Every
`lib/features/<name>/<name>_history.md` stays a plain dated changelog table
(unchanged format) — it never contains task checklists, only completed
work log entries.

## `<name>_plan.md` structure

```markdown
# <Feature> — Feature Plan

**Source:** `docs/admen_web_app_ui_functionality.md` §<section>
**Arcle module:** `lib/features/<name>/` (data/domain/presentation, BLoC)
**Status:** <one-line current status>

## Overview
<what this feature is, in 2-4 sentences>

## Screens
<bullet list of screens, per surface (App/Web) if they differ>

## UI Design Plan
- Responsive behavior: what changes between mobile and web (breakpoint,
  layout shape — e.g. single column vs. split-pane), referencing
  `Dimensions.isWeb`/`webBreakpoint`.
- Screen-by-screen layout notes: what's on screen, in what order, which
  shared widgets from `lib/core/common_widgets/` are reused.
- States to design for: loading, empty, error/failure, success — tied to
  the Bloc's actual status enum values.
- Component/interaction notes specific to this feature (e.g. confirm
  dialogs for destructive actions, per the cross-cutting rule in
  `admen_web_app_ui_functionality.md` §5).
- Explicitly note which widgets are StatefulWidget and *why* (per this
  project's preference: default to StatelessWidget + BlocBuilder/
  BlocConsumer; a StatefulWidget is only justified by something a State
  object must own, e.g. `TextEditingController`/`FocusNode` lifecycle —
  never for state the Bloc should own instead).

## Firebase Section
- [ ]/[x] checklist of every Firestore/Firebase operation this feature
  performs (reads, writes, batches, streams), each annotated with the
  usecase/class that implements it once done. This is the section that
  existed before as "Firebase Connection Tasks" — same content, renamed
  for consistency with the sections below.

## Backend API (Future)
For every operation in the Firebase Section, the REST shape it would take
once `XApiSource implements XRemoteSource` exists (see
`docs/14_APP_ARCHITECTURE.md` and the Source/Repository separation
established in this codebase — only the Source class changes on a backend
swap, per the design walked through during the Auth feature build).
Document per-operation:

```markdown
### <Operation name>
- **Method & path:** `POST /resource/{id}/action`
- **Request body:**
  ```json
  { "field": "value" }
  ```
- **Response body:**
  ```json
  { "field": "value" }
  ```
- **Errors:** notable non-2xx cases and what they mean
```

Mark realtime-listener operations explicitly as "no REST equivalent —
requires WebSocket/SSE, or approximate via polling" rather than inventing a
one-shot endpoint for something that's inherently a stream.

## Architecture notes
<kept as-is from the existing convention — which core services this
feature uses, where its swappable Source boundary is, any deliberate
simplifications/deferrals and why>

## Notes
<anything else — rules-layer dependencies, known limitations, etc.>
```

## `<name>_history.md` structure (unchanged)

```markdown
# <Feature> — History

| Date | Event | Details |
|---|---|---|
| YYYY-MM-DD | Feature scaffolded | ... |
| YYYY-MM-DD | Plan drafted | ... |
| YYYY-MM-DD | Data/domain/presentation implemented | ... |
| YYYY-MM-DD | UI implemented | ... |
```

One row per significant milestone, newest at the bottom. Never delete a row
— corrections get a new row, not an edit to history.
