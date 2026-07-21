// Data-layer re-export: `PollModel`/`PollVoteModel` (from `core/models/`)
// are the parsing DTOs for this feature's `data/source/polls_remote_source.dart`.
// The domain layer never imports this file — only
// `domain/entity/polls_entity.dart`'s plain entities. See
// `lib/core/models/README.md`.
export '../../../../core/models/poll_model.dart';
