/// Barrel export for every data-layer Model class (the Firestore-parsing
/// DTOs that extend their sibling Entity in `models.dart`).
///
/// Import this from a `data/source/*_remote_source.dart` file when you need
/// `fromJson`/`toJson`/`fromEntity` — never from `domain/` or
/// `presentation/`, which should only ever reference the plain Entity types
/// exported by `models.dart`.
library;

export 'announcement_model.dart';
export 'apartment_model.dart';
export 'apartment_request_model.dart';
export 'building_model.dart';
export 'conversation_model.dart';
export 'notification_model.dart';
export 'poll_model.dart';
export 'post_model.dart';
export 'user_model.dart';
