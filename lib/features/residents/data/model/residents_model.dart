// Data-layer re-export: `UserModel`/`ApartmentRequestModel`/`ApartmentModel`
// (from `core/models/`) are the parsing DTOs for this feature's
// `data/source/residents_remote_source.dart`. The domain layer never
// imports this file — only `domain/entity/residents_entity.dart`'s plain
// entities. See `lib/core/models/README.md`.
export '../../../../core/models/apartment_model.dart';
export '../../../../core/models/apartment_request_model.dart';
export '../../../../core/models/user_model.dart';
