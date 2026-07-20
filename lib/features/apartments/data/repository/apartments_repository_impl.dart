import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/apartment_status.dart';
import '../../../../core/models/user_entity.dart';
import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entity/apartments_entity.dart';
import '../../domain/repository/apartments_repository.dart';
import '../source/apartments_remote_source.dart';

@LazySingleton(as: ApartmentsRepository)
class ApartmentsRepositoryImpl implements ApartmentsRepository {
  ApartmentsRepositoryImpl(this._remote);

  final ApartmentsRemoteSource _remote;

  @override
  Stream<List<ApartmentEntity>> watchApartments(String buildingId) =>
      _remote.watchApartments(buildingId);

  @override
  Future<Result<void>> createApartment(ApartmentEntity apartment) async {
    try {
      await _remote.createApartment(apartment);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> updateApartment(ApartmentEntity apartment) async {
    try {
      await _remote.updateApartment(apartment);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> deleteApartment(String apartmentId) async {
    try {
      await _remote.deleteApartment(apartmentId);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<void>> setStatus(String apartmentId, ApartmentStatus status) async {
    if (status == ApartmentStatus.occupied) {
      return const Left(ValidationFailure(
        'An apartment can only become occupied by approving a resident request.',
      ));
    }
    try {
      await _remote.updateStatus(apartmentId, status);
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }

  @override
  Future<Result<UserEntity?>> resolvePrimaryResident(String uid) async {
    try {
      return Right(await _remote.fetchUser(uid));
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
