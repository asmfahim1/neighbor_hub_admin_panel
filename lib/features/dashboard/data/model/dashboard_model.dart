// No feature-local model: the Dashboard reads `ApartmentEntity`,
// `ApartmentRequestEntity`, `PostEntity`, and `AnnouncementEntity` directly
// from `core/models/` and composes them into `DashboardEntity` — a
// feature-local *aggregate*, not a 1:1 Firestore document mirror. See
// `lib/core/models/README.md`.
