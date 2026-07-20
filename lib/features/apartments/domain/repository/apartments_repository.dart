import '../../../../core/constants/apartment_status.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/utils/result.dart';
import '../entity/apartments_entity.dart';

abstract class ApartmentsRepository {
  /// Realtime listener on `apartments where buildingId == X`.
  Stream<List<ApartmentEntity>> watchApartments(String buildingId);

  Future<Result<void>> createApartment(ApartmentEntity apartment);

  Future<Result<void>> updateApartment(ApartmentEntity apartment);

  Future<Result<void>> deleteApartment(String apartmentId);

  /// Direct status toggle — [ApartmentStatus.vacant] and
  /// [ApartmentStatus.blocked] only. Setting [ApartmentStatus.occupied] is
  /// rejected here by design: it only happens via the Residents approval
  /// `WriteBatch` (§7.5.1).
  Future<Result<void>> setStatus(String apartmentId, ApartmentStatus status);

  /// Resolves `primaryResidentUid` → `users/{uid}` for display when an
  /// apartment is occupied.
  Future<Result<UserEntity?>> resolvePrimaryResident(String uid);
}
