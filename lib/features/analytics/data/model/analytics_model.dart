// No feature-local model: the Analytics feature reads `ApartmentEntity`,
// `PostEntity`, and `PollEntity` directly from `core/models/` and composes
// them into `AnalyticsEntity` — a feature-local *aggregate*, not a 1:1
// Firestore document mirror. See `lib/core/models/README.md`.
