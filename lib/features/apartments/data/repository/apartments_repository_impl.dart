import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/apartments_entity.dart';
import '../../domain/repository/apartments_repository.dart';
// import '../model/apartments_model.dart';
import '../source/apartments_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: ApartmentsRepository)

class ApartmentsRepositoryImpl implements ApartmentsRepository {
  ApartmentsRepositoryImpl(this._remote);

  final ApartmentsRemoteSource _remote;

  @override
  Future<Result<List<ApartmentsEntity>>> getApartmentsData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
