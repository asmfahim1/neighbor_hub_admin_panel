// Data-layer re-export: `ConversationModel`/`MessageModel` (from
// `core/models/`) are the parsing DTOs for this feature's
// `data/source/chat_remote_source.dart`. The domain layer never imports
// this file — only `domain/entity/chat_entity.dart`'s plain entities. See
// `lib/core/models/README.md`.
export '../../../../core/models/conversation_model.dart';
