import '../../../../core/response_handler/api_failure.dart';
import '../../../../core/utils/result.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entity/auth_entity.dart';
import '../../domain/repository/auth_repository.dart';
// import '../model/auth_model.dart';
import '../source/auth_remote_source.dart';
import 'package:injectable/injectable.dart';


@LazySingleton(as: AuthRepository)

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteSource _remote;

  @override
  Future<Result<List<AuthEntity>>> getAuthData() async {
    try {
      final models = await _remote.fetchData();
      final entities = models.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
