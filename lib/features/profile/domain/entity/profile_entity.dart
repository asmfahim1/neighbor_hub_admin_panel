// Re-export shim: the signed-in admin's own profile is a 1:1 `users/{uid}`
// document mirror, so its canonical entity lives in `lib/core/models/`
// (single source of truth). See `lib/core/models/README.md`.
export '../../../../core/models/user_entity.dart';
