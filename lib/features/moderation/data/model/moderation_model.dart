// Data-layer re-export: `PostModel`/`PostAuthorshipModel`/`CommentModel`
// (from `core/models/`) are the parsing DTOs for this feature's
// `data/source/moderation_remote_source.dart`. The domain layer never
// imports this file — only `domain/entity/moderation_entity.dart`'s plain
// entities. See `lib/core/models/README.md`.
export '../../../../core/models/post_model.dart';
