// Auth has no Firestore-document-shaped "model" of its own — its data comes
// from `core/models/user_entity.dart` (`UserEntity` / `UserPrivateAccountEntity`)
// via `data/source/auth_remote_source.dart`, and the composed session result
// is `domain/entity/auth_entity.dart` (`AuthSessionEntity`). This file is kept
// as a placeholder so the arcle-scaffolded folder layout stays meaningful;
// see `lib/core/models/README.md` for why models live in `core/models`.
