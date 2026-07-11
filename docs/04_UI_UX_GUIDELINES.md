# 04_UI_UX_GUIDELINES.md

# NeighborHub — UI/UX Guidelines

**Version:** 0.1 (Planning Phase)
**Note:** This is a design *philosophy* document, not a Figma spec. No visual design work exists yet — this defines the rules any future screen design must follow, so the eventual UI stays consistent from the first screen designed to the last.

## 1. Purpose

Establish a consistent design language for NeighborHub before any screen is drawn, so that:

* Every future screen has a clear visual and interaction baseline to follow
* Light and Dark themes are treated as first-class from day one, not retrofitted
* The product feels like a calm, trustworthy community tool — not a social-media clone

## 2. Scope

Covers: design principles, theming (light/dark), typography, component styling rules, navigation pattern, empty/loading/error states, motion, and accessibility — for both the **Resident App** and the **Admin App/Web Portal** (which share the same design language but differ in density, per §11).

## 3. Design Principles

1. **Modern & Minimal** — no visual clutter; every element earns its place.
2. **Community-first, not social-media** — no infinite-scroll gamification, no follower counts, no vanity metrics. Reactions/comments/bookmarks exist to help neighbors communicate, not to maximize engagement time.
3. **Material 3** — use Material 3 as the base design system (Flutter's native support), extended with NeighborHub's own color tokens.
4. **Fast** — every screen should feel instant; prefer skeleton loaders over spinners, and cached/offline data over blank screens.
5. **Text-first** — since the product excludes images/media by design, typography, color, and spacing carry the visual weight instead of photos.
6. **Accessible by default** — sufficient contrast and tap-target sizing in both themes, not just one.

## 4. Theming — Light & Dark

Both themes must be designed together, not light-first-then-ported.

### 4.1 Color Tokens

| Token | Purpose | Light | Dark |
|---|---|---|---|
| `primary` | Brand accent, primary buttons, active nav item | Deep community blue/teal | Lighter tint of same hue for contrast on dark surfaces |
| `secondary` | Secondary actions, highlights | Warm neutral accent | Muted version of light equivalent |
| `background` | Screen background | Near-white (`#FAFAFA`-ish) | Near-black (`#121212`-ish) |
| `surface` | Cards, sheets, dialogs | White | Dark gray, slightly lighter than background |
| `onSurface` | Text/icons on surface | Near-black | Near-white |
| `error` | Destructive actions, delete confirmations | Standard Material red | Slightly desaturated red for dark backgrounds |
| `success` | Approval, confirmation states | Green | Lighter green for dark contrast |
| `outline` | Dividers, input borders | Light gray | Medium gray |

*(Exact hex values are a design-phase decision once branding is picked — this table defines the token contract, not final colors.)*

### 4.2 Category Color Coding (Post Types)

Each post category gets a consistent chip color, same hue family across both themes (dark theme = same hue, adjusted lightness/saturation for contrast):

* `Discussion` — blue chip
* `Recommendation` — purple chip
* `Help` — orange/amber chip (urgency cue, e.g. "Need blood donor tomorrow")
* `Service` — teal/green chip
* `Anonymous` — neutral gray chip, always paired with a generic person icon, never a category color (keeps anonymity visually distinct from categorized posts)

### 4.3 Theme Switching

* Respect system theme by default; allow manual override in Profile/Settings.
* No screen should hardcode a color outside the token set — all components consume tokens so a single theme switch updates the whole app.

## 5. Typography

* One clean, highly-legible sans-serif family (system default acceptable, e.g. Roboto/SF equivalents via Flutter's Material text theme) — no display/decorative fonts.
* Scale: Headline (screen titles) → Title (card headers, resident names) → Body (post content, chat messages) → Caption (timestamps, meta info like "2 hours ago").
* Consistent weight rules: names/titles medium-bold, body regular, timestamps/meta lighter and smaller for hierarchy without extra color reliance.

## 6. Component Styling

### 6.1 Cards

* **Post Card:** author row (avatar/icon + name or "Anonymous Resident" + timestamp) → category chip → text body → action row (react, comment, bookmark counts). Consistent padding/radius across feed, pinned posts, and moderation views.
* **Chat List Item:** avatar/icon, resident name, last message preview, timestamp, unread indicator.
* **Notification Item:** category icon (matches the 5 notification categories), short message, timestamp, read/unread state.

### 6.2 Avatars

* Google-authenticated resident → their Google profile photo.
* Email/password resident (no photo) → default person icon (single consistent icon asset, theme-aware — different tonal treatment in dark vs light).
* Anonymous post/comment → generic "Anonymous" icon, visually distinct from the default person icon so residents can tell "no photo available" apart from "intentionally anonymous."

### 6.3 Buttons

* Primary (filled) — main actions: Create Post, Approve, Send Message.
* Secondary (outlined/tonal) — supporting actions: Cancel, Save Draft.
* Text buttons — low-emphasis actions: "Skip," "Not now."
* Destructive actions (delete post, remove resident, delete account) always use the `error` token color and always require a confirmation dialog.

### 6.4 Chips & Badges

* Category chips (§4.2) on posts.
* Status badges on apartments in Admin view: `Vacant` (gray), `Pending Approval` (amber), `Occupied` (green), `Blocked` (red) — same semantic coloring in both themes.

## 7. Navigation Pattern

**Resident App** — bottom navigation, 5 destinations max (matches the core sections defined in `03_RESIDENT_SYSTEM.md`):

`Feed` · `Announcements` · `Chat` · `Notifications` · `Profile`

* "Create Post" is a floating action button on the Feed tab, not a 6th nav destination.

**Admin App** — bottom or drawer navigation covering: `Dashboard` · `Residents/Apartments` · `Feed Moderation` · `Announcements` · `Analytics` · `Profile`.

**Admin Web Portal** — persistent left sidebar (desktop convention) with the same sections as the Admin App, since it's used for heavier data-entry sessions.

## 8. Empty States

Every list-based screen needs a designed empty state, not a blank screen:

* Empty Chat List → "No conversations yet. Start one from the Resident Directory." + CTA button.
* Empty Feed (new building) → "Be the first to post in your community."
* Empty Notifications → "You're all caught up."
* Empty Bookmarks → "Posts you bookmark will show up here."
* Empty Resident Directory (shouldn't normally happen, but) → handled gracefully, not a crash-prone edge case.

## 9. Loading States

* Skeleton/shimmer placeholders for feed cards, chat list, and notification list — never a bare spinner on primary content screens.
* Small inline spinners are acceptable only for button-level actions (e.g., "Posting…" on the submit button).

## 10. Error States

* No-internet banner (non-blocking, dismissible) rather than a full-screen error, since the app is offline-friendly and most reads still work from cache.
* Failed action (e.g., post didn't sync) shows an inline retry affordance on the affected item, not a global alert.
* Form validation errors are inline, under the relevant field, never a popup dialog for simple validation.

## 11. Admin Web Portal vs App — Density Difference

The Web Portal shares the same tokens, typography, and component *style*, but uses a denser, table-oriented layout appropriate for desktop (e.g., an apartments table with inline status editing) where the mobile app uses card-based lists. Same design language, different information density — not a different design system.

## 12. Motion & Animation

* Subtle and purposeful only: card entrance fade/slide on feed load, reaction count "pop" on tap, smooth chat bubble insertion.
* No decorative animation that delays the user from completing a task (e.g., no forced splash animations before reaching the feed).

## 13. Accessibility

* Minimum WCAG AA contrast for text on both light and dark surfaces.
* Minimum 44x44dp tap targets for all interactive elements (react/comment/bookmark icons, nav items).
* Support system font-scaling without breaking card layouts (text should wrap, not truncate critical content like post bodies).
* Icons paired with text labels where meaning isn't obvious from shape alone (e.g., category chips carry text, not just color).

## 14. Notes

* No component in this system should ever require an image upload UI — if a future screen seems to need one, that's a signal it conflicts with the no-media product principle and should be escalated, not quietly designed around.
* Anonymous and "no-photo" states must remain visually distinguishable from each other at all times (§6.2).

## 15. Future Enhancements

* Per-building branding (custom accent color per building) once white-label deployment becomes a business model (see future business model doc)
* Custom illustration set for empty states (currently text+icon only, by design, to avoid scope creep pre-MVP)
* Motion refinement pass once real usage data shows where users hesitate
