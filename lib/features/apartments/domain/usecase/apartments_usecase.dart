import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/utils/result.dart';
import '../entity/apartments_entity.dart';
import '../repository/apartments_repository.dart';

@injectable
class WatchApartmentsUseCase {
  WatchApartmentsUseCase(this._repo);
  final ApartmentsRepository _repo;

  Stream<List<ApartmentEntity>> call(String buildingId) => _repo.watchApartments(buildingId);
}

@injectable
class CreateApartmentUseCase {
  CreateApartmentUseCase(this._repo);
  final ApartmentsRepository _repo;

  Future<Result<void>> call(ApartmentEntity apartment) => _repo.createApartment(apartment);
}

@injectable
class UpdateApartmentUseCase {
  UpdateApartmentUseCase(this._repo);
  final ApartmentsRepository _repo;

  Future<Result<void>> call(ApartmentEntity apartment) => _repo.updateApartment(apartment);
}

@injectable
class DeleteApartmentUseCase {
  DeleteApartmentUseCase(this._repo);
  final ApartmentsRepository _repo;

  Future<Result<void>> call(String apartmentId) => _repo.deleteApartment(apartmentId);
}

@injectable
class SetApartmentStatusUseCase {
  SetApartmentStatusUseCase(this._repo);
  final ApartmentsRepository _repo;

  Future<Result<void>> call(String apartmentId, ApartmentStatus status) =>
      _repo.setStatus(apartmentId, status);
}

@injectable
class ResolvePrimaryResidentUseCase {
  ResolvePrimaryResidentUseCase(this._repo);
  final ApartmentsRepository _repo;

  Future<Result<UserEntity?>> call(String uid) => _repo.resolvePrimaryResident(uid);
}
