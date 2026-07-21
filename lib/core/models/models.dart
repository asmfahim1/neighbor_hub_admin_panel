/// Barrel export for every shared, framework-agnostic domain entity — pure
/// fields and business logic, zero Firestore/JSON knowledge.
///
/// Import this from `domain/`, `presentation/`, or a repository
/// implementation. For the data-layer DTOs that actually parse/serialize
/// these (used only inside `data/source/*_remote_source.dart` files), see
/// `data_models.dart` instead.
library;

export 'announcement_entity.dart';
export 'apartment_entity.dart';
export 'apartment_request_entity.dart';
export 'building_entity.dart';
export 'conversation_entity.dart';
export 'notification_entity.dart';
export 'poll_entity.dart';
export 'post_entity.dart';
export 'user_entity.dart';
